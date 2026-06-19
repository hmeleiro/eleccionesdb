.edb_sqlite_required_tables <- c(
    "tipos_eleccion", "elecciones", "territorios", "partidos_recode",
    "partidos", "resumen_territorial", "votos_territoriales"
)

#' @noRd
edb_sqlite_connect <- function(path = edb_sqlite_active_path()) {
    edb_require_sqlite()
    DBI::dbConnect(RSQLite::SQLite(), path, flags = RSQLite::SQLITE_RO)
}

#' @noRd
edb_sqlite_validate <- function(path, quick = FALSE) {
    edb_require_sqlite()
    con <- DBI::dbConnect(RSQLite::SQLite(), path, flags = RSQLite::SQLITE_RO)
    on.exit(DBI::dbDisconnect(con), add = TRUE)

    tables <- DBI::dbListTables(con)
    missing <- setdiff(.edb_sqlite_required_tables, tables)
    if (length(missing) > 0L) {
        cli::cli_abort("La base SQLite no contiene las tablas requeridas: {paste(missing, collapse = ', ')}.")
    }
    version <- DBI::dbGetQuery(con, "PRAGMA user_version")[[1]][[1]]
    if (!identical(as.integer(version), 1L)) {
        cli::cli_abort("Version de esquema SQLite no compatible: {version}.")
    }
    resumen_cols <- DBI::dbListFields(con, "resumen_territorial")
    required_cols <- c(
        "id", "eleccion_id", "territorio_id", "censo_ine",
        "participacion_1", "participacion_2", "participacion_3",
        "votos_validos", "abstenciones", "votos_blancos", "votos_nulos",
        "nrepresentantes"
    )
    missing_cols <- setdiff(required_cols, resumen_cols)
    if (length(missing_cols) > 0L) {
        cli::cli_abort("La tabla resumen_territorial no contiene: {paste(missing_cols, collapse = ', ')}.")
    }
    if (isTRUE(quick)) {
        result <- DBI::dbGetQuery(con, "PRAGMA quick_check")[[1]][[1]]
        if (!identical(result, "ok")) {
            cli::cli_abort("La comprobacion de integridad SQLite ha fallado: {result}.")
        }
    }
    invisible(TRUE)
}

#' @noRd
sqlite_validate_pagination <- function(limit, skip) {
    if (length(limit) != 1L || is.na(limit) || limit < 1L || limit > 500L) {
        cli::cli_abort("{.arg limit} debe estar entre 1 y 500.")
    }
    if (length(skip) != 1L || is.na(skip) || skip < 0L) {
        cli::cli_abort("{.arg skip} debe ser mayor o igual que 0.")
    }
    invisible(TRUE)
}

#' @noRd
sqlite_add_in_filter <- function(state, column, values) {
    if (is.null(values) || length(values) == 0L) return(state)
    values <- unlist(values, use.names = FALSE)
    state$clauses <- c(
        state$clauses,
        paste0(column, " IN (", paste(rep("?", length(values)), collapse = ", "), ")")
    )
    state$params <- c(state$params, as.list(values))
    state
}

#' @noRd
sqlite_add_like_filter <- function(state, column, value) {
    if (is.null(value) || length(value) == 0L) return(state)
    state$clauses <- c(state$clauses, paste0("LOWER(", column, ") LIKE LOWER(?)"))
    state$params <- c(state$params, list(paste0("%", value[[1]], "%")))
    state
}

#' @noRd
sqlite_where <- function(state) {
    if (length(state$clauses) == 0L) "" else paste("WHERE", paste(state$clauses, collapse = " AND "))
}

#' @noRd
sqlite_query <- function(select, from, state = list(clauses = character(), params = list()),
                         order_by = NULL, limit = 50L, skip = 0L,
                         all_pages = FALSE) {
    sqlite_validate_pagination(limit, skip)
    con <- edb_sqlite_connect()
    on.exit(DBI::dbDisconnect(con), add = TRUE)
    where <- sqlite_where(state)
    count_sql <- paste("SELECT COUNT(*) AS n", from, where)
    total <- DBI::dbGetQuery(con, count_sql, params = state$params)[["n"]][[1]]

    sql <- paste("SELECT", select, from, where)
    if (!is.null(order_by)) sql <- paste(sql, "ORDER BY", order_by)
    effective_skip <- if (isTRUE(all_pages)) 0L else as.integer(skip)
    if (!isTRUE(all_pages)) sql <- paste(sql, "LIMIT ? OFFSET ?")
    params <- state$params
    if (!isTRUE(all_pages)) params <- c(params, list(as.integer(limit), effective_skip))
    tbl <- tibble::as_tibble(DBI::dbGetQuery(con, sql, params = params))
    attr(tbl, "edb_total") <- as.integer(total)
    attr(tbl, "edb_skip") <- effective_skip
    attr(tbl, "edb_limit") <- if (isTRUE(all_pages)) as.integer(total) else as.integer(limit)
    tbl
}

#' @noRd
sqlite_query_one <- function(select, from, state, not_found = "Recurso no encontrado") {
    tbl <- sqlite_query(select, from, state, order_by = NULL, limit = 1L)
    if (nrow(tbl) == 0L) cli::cli_abort(not_found)
    for (nm in c("edb_total", "edb_skip", "edb_limit")) attr(tbl, nm) <- NULL
    tbl
}

#' @noRd
sqlite_fact_filters <- function(eleccion_id = NULL, territorio_id = NULL,
                                partido_id = NULL, year = NULL,
                                tipo_eleccion = NULL, tipo_territorio = NULL,
                                codigo_ccaa = NULL, codigo_provincia = NULL,
                                codigo_municipio = NULL, alias = "f") {
    state <- list(clauses = character(), params = list())
    state <- sqlite_add_in_filter(state, paste0(alias, ".eleccion_id"), eleccion_id)
    state <- sqlite_add_in_filter(state, paste0(alias, ".territorio_id"), territorio_id)
    if (!is.null(partido_id)) {
        state <- sqlite_add_in_filter(state, paste0(alias, ".partido_id"), partido_id)
    }
    state <- sqlite_add_in_filter(state, "e.year", year)
    state <- sqlite_add_in_filter(state, "e.tipo_eleccion", tipo_eleccion)
    state <- sqlite_add_in_filter(state, "t.tipo", tipo_territorio)
    state <- sqlite_add_in_filter(state, "t.codigo_ccaa", codigo_ccaa)
    state <- sqlite_add_in_filter(state, "t.codigo_provincia", codigo_provincia)
    sqlite_add_in_filter(state, "t.codigo_municipio", codigo_municipio)
}

#' @noRd
sqlite_get_tipos_eleccion <- function() {
    con <- edb_sqlite_connect()
    on.exit(DBI::dbDisconnect(con), add = TRUE)
    tibble::as_tibble(DBI::dbGetQuery(
        con, "SELECT codigo, descripcion FROM tipos_eleccion ORDER BY codigo"
    ))
}

#' @noRd
sqlite_get_tipo_eleccion <- function(codigo) {
    state <- sqlite_add_in_filter(list(clauses = character(), params = list()), "codigo", codigo)
    sqlite_query_one("codigo, descripcion", "FROM tipos_eleccion", state,
                     "Tipo de eleccion no encontrado.")
}

#' @noRd
sqlite_get_elecciones <- function(tipo_eleccion = NULL, year = NULL, mes = NULL,
                                  ambito = NULL, limit = 50L, skip = 0L,
                                  all_pages = FALSE) {
    state <- list(clauses = character(), params = list())
    state <- sqlite_add_in_filter(state, "e.tipo_eleccion", tipo_eleccion)
    state <- sqlite_add_in_filter(state, "e.year", year)
    state <- sqlite_add_in_filter(state, "e.mes", mes)
    state <- sqlite_add_in_filter(state, "e.ambito", ambito)
    sqlite_query("e.*", "FROM elecciones e", state, "e.id", limit, skip, all_pages) |>
        coerce_dates()
}

#' @noRd
sqlite_get_eleccion <- function(eleccion_id) {
    state <- sqlite_add_in_filter(list(clauses = character(), params = list()), "e.id", eleccion_id)
    tbl <- sqlite_query_one(
        paste(
            "e.*, te.codigo AS tipo_codigo,",
            "te.descripcion AS tipo_descripcion"
        ),
        "FROM elecciones e LEFT JOIN tipos_eleccion te ON te.codigo = e.tipo_eleccion",
        state, "Eleccion no encontrada."
    )
    coerce_dates(tbl)
}

#' @noRd
sqlite_get_territorios <- function(tipo = NULL, codigo_ccaa = NULL,
                                   codigo_provincia = NULL, codigo_municipio = NULL,
                                   codigo_circunscripcion = NULL, nombre = NULL,
                                   limit = 50L, skip = 0L, all_pages = FALSE,
                                   parent_id = NULL) {
    state <- list(clauses = character(), params = list())
    state <- sqlite_add_in_filter(state, "t.tipo", tipo)
    state <- sqlite_add_in_filter(state, "t.codigo_ccaa", codigo_ccaa)
    state <- sqlite_add_in_filter(state, "t.codigo_provincia", codigo_provincia)
    state <- sqlite_add_in_filter(state, "t.codigo_municipio", codigo_municipio)
    state <- sqlite_add_in_filter(state, "t.codigo_circunscripcion", codigo_circunscripcion)
    state <- sqlite_add_in_filter(state, "t.parent_id", parent_id)
    state <- sqlite_add_like_filter(state, "t.nombre", nombre)
    sqlite_query("t.*", "FROM territorios t", state, "t.id", limit, skip, all_pages)
}

#' @noRd
sqlite_get_territorio <- function(territorio_id) {
    state <- sqlite_add_in_filter(list(clauses = character(), params = list()), "id", territorio_id)
    sqlite_query_one("*", "FROM territorios", state, "Territorio no encontrado.")
}

#' @noRd
sqlite_get_partidos <- function(siglas = NULL, denominacion = NULL,
                                partido_recode_id = NULL, limit = 50L,
                                skip = 0L, all_pages = FALSE) {
    state <- list(clauses = character(), params = list())
    state <- sqlite_add_like_filter(state, "p.siglas", siglas)
    state <- sqlite_add_like_filter(state, "p.denominacion", denominacion)
    state <- sqlite_add_in_filter(state, "p.partido_recode_id", partido_recode_id)
    sqlite_query("p.*", "FROM partidos p", state, "p.id", limit, skip, all_pages)
}

#' @noRd
sqlite_get_partido <- function(partido_id) {
    state <- sqlite_add_in_filter(list(clauses = character(), params = list()), "p.id", partido_id)
    sqlite_query_one(
        paste(
            "p.*, pr.id AS recode_id, pr.partido_recode AS recode_partido_recode,",
            "pr.agrupacion AS recode_agrupacion, pr.color AS recode_color"
        ),
        "FROM partidos p LEFT JOIN partidos_recode pr ON pr.id = p.partido_recode_id",
        state, "Partido no encontrado."
    )
}

#' @noRd
sqlite_get_partidos_recode <- function(agrupacion = NULL, limit = 50L,
                                       skip = 0L, all_pages = FALSE) {
    state <- sqlite_add_like_filter(
        list(clauses = character(), params = list()), "pr.agrupacion", agrupacion
    )
    sqlite_query("pr.*", "FROM partidos_recode pr", state, "pr.id", limit, skip, all_pages)
}

#' @noRd
sqlite_get_partido_recode <- function(partido_recode_id) {
    state <- sqlite_add_in_filter(
        list(clauses = character(), params = list()), "id", partido_recode_id
    )
    recode <- sqlite_query_one("*", "FROM partidos_recode", state,
                               "Grupo de partidos no encontrado.")
    partidos <- sqlite_get_partidos(partido_recode_id = partido_recode_id,
                                    all_pages = TRUE)
    for (nm in c("edb_total", "edb_skip", "edb_limit")) attr(partidos, nm) <- NULL
    list(recode = recode, partidos = partidos)
}

#' @noRd
sqlite_get_totales <- function(eleccion_id = NULL, territorio_id = NULL,
                               year = NULL, tipo_eleccion = NULL,
                               tipo_territorio = NULL, codigo_ccaa = NULL,
                               codigo_provincia = NULL, codigo_municipio = NULL,
                               limit = 50L, skip = 0L, all_pages = FALSE) {
    state <- sqlite_fact_filters(
        eleccion_id, territorio_id, year = year,
        tipo_eleccion = tipo_eleccion, tipo_territorio = tipo_territorio,
        codigo_ccaa = codigo_ccaa, codigo_provincia = codigo_provincia,
        codigo_municipio = codigo_municipio, alias = "r"
    )
    sqlite_query(
        "r.*",
        paste(
            "FROM resumen_territorial r",
            "JOIN elecciones e ON e.id = r.eleccion_id",
            "JOIN territorios t ON t.id = r.territorio_id"
        ), state, "r.id", limit, skip, all_pages
    )
}

#' @noRd
sqlite_get_votos <- function(eleccion_id = NULL, territorio_id = NULL,
                             partido_id = NULL, year = NULL,
                             tipo_eleccion = NULL, tipo_territorio = NULL,
                             codigo_ccaa = NULL, codigo_provincia = NULL,
                             codigo_municipio = NULL, limit = 50L, skip = 0L,
                             all_pages = FALSE) {
    state <- sqlite_fact_filters(
        eleccion_id, territorio_id, partido_id, year, tipo_eleccion,
        tipo_territorio, codigo_ccaa, codigo_provincia, codigo_municipio,
        alias = "v"
    )
    sqlite_query(
        "v.*",
        paste(
            "FROM votos_territoriales v",
            "JOIN elecciones e ON e.id = v.eleccion_id",
            "JOIN territorios t ON t.id = v.territorio_id"
        ), state, "v.id", limit, skip, all_pages
    )
}

#' @noRd
sqlite_get_resultado_completo <- function(eleccion_id, territorio_id) {
    totales <- sqlite_get_totales(eleccion_id, territorio_id, limit = 1L)
    if (nrow(totales) == 0L) totales <- tibble::tibble()
    for (nm in c("edb_total", "edb_skip", "edb_limit")) attr(totales, nm) <- NULL

    state <- sqlite_fact_filters(eleccion_id, territorio_id, alias = "v")
    votos <- sqlite_query(
        paste(
            "v.*, p.siglas AS partido_siglas,",
            "p.denominacion AS partido_denominacion,",
            "p.partido_recode_id AS partido_partido_recode_id"
        ),
        paste(
            "FROM votos_territoriales v",
            "JOIN elecciones e ON e.id = v.eleccion_id",
            "JOIN territorios t ON t.id = v.territorio_id",
            "JOIN partidos p ON p.id = v.partido_id"
        ), state, "v.votos DESC", 500L, 0L, TRUE
    )
    for (nm in c("edb_total", "edb_skip", "edb_limit")) attr(votos, nm) <- NULL
    list(totales_territorio = totales, votos_partido = votos)
}

#' @noRd
sqlite_get_resultados <- function(eleccion_id = NULL, territorio_id = NULL,
                                  partido_id = NULL, year = NULL,
                                  tipo_eleccion = NULL, tipo_territorio = NULL,
                                  codigo_ccaa = NULL, codigo_provincia = NULL,
                                  codigo_municipio = NULL, limit = 50L,
                                  skip = 0L, all_pages = TRUE) {
    state <- sqlite_fact_filters(
        eleccion_id, territorio_id, partido_id, year, tipo_eleccion,
        tipo_territorio, codigo_ccaa, codigo_provincia, codigo_municipio,
        alias = "v"
    )
    select <- paste(
        "v.id, v.eleccion_id, v.territorio_id, v.partido_id, v.votos, v.representantes,",
        "p.siglas AS partido_siglas,",
        "p.denominacion AS partido_denominacion,",
        "p.partido_recode_id AS partido_partido_recode_id,",
        "pr.id AS recode_id, pr.partido_recode AS recode_partido_recode,",
        "pr.agrupacion AS recode_agrupacion, pr.color AS recode_color,",
        "t.tipo AS territorio_tipo,",
        "t.nombre AS territorio_nombre, t.codigo_completo AS territorio_codigo_completo,",
        "t.codigo_ccaa AS territorio_codigo_ccaa,",
        "t.codigo_provincia AS territorio_codigo_provincia,",
        "t.codigo_municipio AS territorio_codigo_municipio,",
        "t.codigo_distrito AS territorio_codigo_distrito,",
        "t.codigo_seccion AS territorio_codigo_seccion,",
        "t.codigo_circunscripcion AS territorio_codigo_circunscripcion,",
        "e.tipo_eleccion AS eleccion_tipo_eleccion,",
        "e.year AS eleccion_year, e.mes AS eleccion_mes, e.dia AS eleccion_dia,",
        "e.fecha AS eleccion_fecha, e.descripcion AS eleccion_descripcion,",
        "e.ambito AS eleccion_ambito, e.slug AS eleccion_slug,",
        "r.censo_ine, r.votos_validos, r.abstenciones, r.votos_blancos,",
        "r.votos_nulos, r.participacion_1, r.participacion_2, r.participacion_3,",
        "r.nrepresentantes"
    )
    sqlite_query(
        select,
        paste(
            "FROM votos_territoriales v",
            "JOIN elecciones e ON e.id = v.eleccion_id",
            "JOIN territorios t ON t.id = v.territorio_id",
            "JOIN partidos p ON p.id = v.partido_id",
            "LEFT JOIN partidos_recode pr ON pr.id = p.partido_recode_id",
            "LEFT JOIN resumen_territorial r",
            "ON r.eleccion_id = v.eleccion_id AND r.territorio_id = v.territorio_id"
        ), state, "v.id", limit, skip, all_pages
    )
}

#' @noRd
sqlite_lookup_labels <- function(kind, ids, use_recode = FALSE) {
    ids <- unique(ids[!is.na(ids)])
    if (length(ids) == 0L) return(stats::setNames(character(), character()))
    state <- sqlite_add_in_filter(list(clauses = character(), params = list()), "x.id", ids)
    if (identical(kind, "eleccion")) {
        tbl <- sqlite_query("x.id, x.descripcion AS value", "FROM elecciones x", state,
                            all_pages = TRUE)
    } else if (identical(kind, "territorio")) {
        tbl <- sqlite_query("x.id, x.nombre AS value", "FROM territorios x", state,
                            all_pages = TRUE)
    } else {
        value <- if (isTRUE(use_recode)) "COALESCE(pr.agrupacion, x.siglas)" else "x.siglas"
        tbl <- sqlite_query(
            paste0("x.id, ", value, " AS value"),
            "FROM partidos x LEFT JOIN partidos_recode pr ON pr.id = x.partido_recode_id",
            state, all_pages = TRUE
        )
    }
    stats::setNames(as.character(tbl[["value"]]), as.character(tbl[["id"]]))
}
