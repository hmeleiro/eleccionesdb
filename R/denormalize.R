#' Denormalize ID columns in a result tibble
#'
#' Resolves ID columns (`eleccion_id`, `territorio_id`, `partido_id`) to
#' human-readable names by fetching the corresponding records from the API.
#' Each descriptive column is inserted immediately after its ID column.
#'
#' @param tbl A tibble with ID columns to denormalize.
#' @param use_recode Logical. If `TRUE` and `partido_id` is present, use the
#'   recode agrupacion as party name instead of the raw party siglas.
#'   Falls back to siglas when the party has no recode. Default `FALSE`.
#' @return The tibble with descriptive columns inserted after each ID column.
#'   Pagination attributes (`edb_total`, `edb_skip`, `edb_limit`) are preserved.
#' @noRd
denormalize_tbl <- function(tbl, use_recode = FALSE) {
    if (nrow(tbl) == 0) {
        return(tbl)
    }

    # Preserve pagination attributes
    pag_attrs <- list(
        edb_total = attr(tbl, "edb_total"),
        edb_skip = attr(tbl, "edb_skip"),
        edb_limit = attr(tbl, "edb_limit")
    )

    if ("eleccion_id" %in% names(tbl)) {
        tbl <- add_eleccion_desc(tbl)
    }

    if ("territorio_id" %in% names(tbl)) {
        tbl <- add_territorio_nombre(tbl)
    }

    if ("partido_id" %in% names(tbl)) {
        tbl <- add_partido_nombre(tbl, use_recode)
    }

    # Restore pagination attributes
    for (nm in names(pag_attrs)) {
        if (!is.null(pag_attrs[[nm]])) {
            attr(tbl, nm) <- pag_attrs[[nm]]
        }
    }

    tbl
}

#' Add eleccion_descripcion column after eleccion_id
#' @noRd
add_eleccion_desc <- function(tbl) {
    ids <- unique(tbl[["eleccion_id"]])
    ids <- ids[!is.na(ids)]

    if (length(ids) == 0) {
        tbl[["eleccion_descripcion"]] <- NA_character_
        return(reorder_after(tbl, "eleccion_id", "eleccion_descripcion"))
    }

    if (edb_backend_is_sqlite()) {
        lookup <- sqlite_lookup_labels("eleccion", ids)
        tbl[["eleccion_descripcion"]] <- unname(lookup[as.character(tbl[["eleccion_id"]])])
    } else {
        lookup <- vapply(ids, function(id) {
            tryCatch(
                {
                    json <- edb_get(paste0("/v1/elecciones/", id))
                    json[["descripcion"]] %||% NA_character_
                },
                error = function(err) NA_character_
            )
        }, character(1))
        tbl[["eleccion_descripcion"]] <- lookup[match(tbl[["eleccion_id"]], ids)]
    }
    reorder_after(tbl, "eleccion_id", "eleccion_descripcion")
}

#' Add territorio_nombre column after territorio_id
#' @noRd
add_territorio_nombre <- function(tbl) {
    ids <- unique(tbl[["territorio_id"]])
    ids <- ids[!is.na(ids)]

    if (length(ids) == 0) {
        tbl[["territorio_nombre"]] <- NA_character_
        return(reorder_after(tbl, "territorio_id", "territorio_nombre"))
    }

    if (edb_backend_is_sqlite()) {
        lookup <- sqlite_lookup_labels("territorio", ids)
        tbl[["territorio_nombre"]] <- unname(lookup[as.character(tbl[["territorio_id"]])])
    } else {
        lookup <- vapply(ids, function(id) {
            tryCatch(
                {
                    json <- edb_get(paste0("/v1/territorios/", id))
                    json[["nombre"]] %||% NA_character_
                },
                error = function(err) NA_character_
            )
        }, character(1))
        tbl[["territorio_nombre"]] <- lookup[match(tbl[["territorio_id"]], ids)]
    }
    reorder_after(tbl, "territorio_id", "territorio_nombre")
}

#' Add partido_nombre column after partido_id
#'
#' When `use_recode = TRUE`, the column contains the recode `agrupacion`
#' instead of the party `siglas`, falling back to `siglas` when the party
#' has no recode group assigned.
#'
#' @noRd
add_partido_nombre <- function(tbl, use_recode = FALSE) {
    ids <- unique(tbl[["partido_id"]])
    ids <- ids[!is.na(ids)]

    if (length(ids) == 0) {
        tbl[["partido_nombre"]] <- NA_character_
        return(reorder_after(tbl, "partido_id", "partido_nombre"))
    }

    if (edb_backend_is_sqlite()) {
        lookup <- sqlite_lookup_labels("partido", ids, use_recode)
        tbl[["partido_nombre"]] <- unname(lookup[as.character(tbl[["partido_id"]])])
    } else {
        lookup <- vapply(ids, function(id) {
            tryCatch(
                {
                    json <- edb_get(paste0("/v1/partidos/", id))
                    if (use_recode) {
                        recode <- json[["recode"]]
                        if (is.list(recode) && !is.null(recode[["agrupacion"]])) {
                            return(recode[["agrupacion"]])
                        }
                    }
                    json[["siglas"]] %||% NA_character_
                },
                error = function(err) NA_character_
            )
        }, character(1))
        tbl[["partido_nombre"]] <- lookup[match(tbl[["partido_id"]], ids)]
    }
    reorder_after(tbl, "partido_id", "partido_nombre")
}

#' Reorder tibble columns to place new_col right after ref_col
#' @noRd
reorder_after <- function(tbl, ref_col, new_col) {
    cols <- names(tbl)
    idx <- which(cols == ref_col)
    others <- setdiff(cols, new_col)

    if (idx < length(others)) {
        new_order <- c(
            others[seq_len(idx)], new_col,
            others[(idx + 1):length(others)]
        )
    } else {
        new_order <- c(others, new_col)
    }
    tbl[new_order]
}

#' Sort a result tibble by the canonical column order
#'
#' Sorts by available columns from the ordered list:
#' year, mes, tipo_eleccion, codigo_ccaa, codigo_provincia,
#' codigo_municipio, codigo_distrito, codigo_seccion (all ascending),
#' then votos (descending). Only present columns are used.
#' Preserves pagination attributes.
#'
#' @param tbl A tibble.
#' @return The sorted tibble.
#' @noRd
sort_result_tbl <- function(tbl) {
    if (nrow(tbl) == 0L) return(tbl)

    pag_attrs <- list(
        edb_total = attr(tbl, "edb_total"),
        edb_skip  = attr(tbl, "edb_skip"),
        edb_limit = attr(tbl, "edb_limit")
    )

    sort_cols <- intersect(
        c(
            "year", "mes", "tipo_eleccion",
            "codigo_ccaa", "codigo_provincia",
            "codigo_municipio", "codigo_distrito", "codigo_seccion"
        ),
        names(tbl)
    )

    if (length(sort_cols) > 0L || "votos" %in% names(tbl)) {
        ord_args <- lapply(sort_cols, function(col) tbl[[col]])
        if ("votos" %in% names(tbl)) {
            ord_args <- c(ord_args, list(-tbl[["votos"]]))
        }
        if (length(ord_args) > 0L) {
            tbl <- tbl[do.call(order, ord_args), ]
            row.names(tbl) <- NULL
        }
    }

    for (nm in names(pag_attrs)) {
        if (!is.null(pag_attrs[[nm]])) {
            attr(tbl, nm) <- pag_attrs[[nm]]
        }
    }
    tbl
}

#' Remove ID and slug columns from a result tibble
#'
#' Drops `id` and any column ending in `_id`, plus slug columns.
#' Preserves pagination attributes.
#'
#' @param tbl A tibble.
#' @return The tibble without ID/slug columns.
#' @noRd
clean_result_tbl <- function(tbl) {
    pag_attrs <- list(
        edb_total = attr(tbl, "edb_total"),
        edb_skip = attr(tbl, "edb_skip"),
        edb_limit = attr(tbl, "edb_limit")
    )

    drop_cols <- grep("^id$|_id$|slug", names(tbl), value = TRUE)
    tbl <- tbl[setdiff(names(tbl), drop_cols)]

    for (nm in names(pag_attrs)) {
        if (!is.null(pag_attrs[[nm]])) {
            attr(tbl, nm) <- pag_attrs[[nm]]
        }
    }
    tbl
}

#' Rename and select clean columns from a combinados-style tibble
#'
#' Renames prefixed columns to short names and selects only the
#' user-friendly subset. Preserves pagination attributes.
#'
#' @param tbl A tibble from `flatten_combinados()`.
#' @return A clean tibble with renamed columns.
#' @noRd
clean_combinados_tbl <- function(tbl) {
    pag_attrs <- list(
        edb_total = attr(tbl, "edb_total"),
        edb_skip = attr(tbl, "edb_skip"),
        edb_limit = attr(tbl, "edb_limit")
    )

    # Derive sub-provincial codes from territorio_codigo_completo
    # Format: ccaa(2) + provincia(2) + municipio(3) + distrito(2) + seccion(4)
    cc <- tbl[["territorio_codigo_completo"]]
    if (!is.null(cc) && length(cc) > 0 && all(nchar(cc) == 13L, na.rm = TRUE)) {
        if (!"territorio_codigo_municipio" %in% names(tbl)) {
            tbl[["territorio_codigo_municipio"]] <- substr(cc, 5, 7)
        }
        if (!"territorio_codigo_distrito" %in% names(tbl)) {
            tbl[["territorio_codigo_distrito"]] <- substr(cc, 8, 9)
        }
        if (!"territorio_codigo_seccion" %in% names(tbl)) {
            tbl[["territorio_codigo_seccion"]] <- substr(cc, 10, 13)
        }
    }

    rename_map <- c(
        eleccion_year = "year",
        eleccion_mes = "mes",
        eleccion_tipo_eleccion = "tipo_eleccion",
        territorio_tipo = "tipo_territorio",
        territorio_nombre = "territorio_nombre",
        territorio_codigo_ccaa = "codigo_ccaa",
        territorio_codigo_provincia = "codigo_provincia",
        territorio_codigo_circunscripcion = "codigo_circunscripcion",
        territorio_codigo_municipio = "codigo_municipio",
        territorio_codigo_distrito = "codigo_distrito",
        territorio_codigo_seccion = "codigo_seccion",
        partido_siglas = "siglas",
        partido_denominacion = "denominacion",
        recode_partido_recode = "partido_recode",
        recode_agrupacion = "partido_agrupacion"
    )

    cols <- names(tbl)
    for (old_name in names(rename_map)) {
        idx <- which(cols == old_name)
        if (length(idx) == 1L) {
            cols[idx] <- rename_map[[old_name]]
        }
    }
    names(tbl) <- cols

    keep_ordered <- c(
        "year", "mes", "tipo_eleccion",
        "tipo_territorio", "territorio_nombre",
        "codigo_ccaa", "codigo_provincia", "codigo_circunscripcion",
        "codigo_municipio", "codigo_distrito", "codigo_seccion",
        "censo_ine", "votos_validos", "abstenciones",
        "votos_blancos", "votos_nulos",
        "participacion_1", "participacion_2", "participacion_3",
        "siglas", "denominacion", "partido_recode", "partido_agrupacion",
        "votos", "representantes", "nrepresentantes"
    )

    keep <- intersect(keep_ordered, names(tbl))
    tbl <- tbl[keep]

    tbl <- sort_result_tbl(tbl)

    for (nm in names(pag_attrs)) {
        if (!is.null(pag_attrs[[nm]])) {
            attr(tbl, nm) <- pag_attrs[[nm]]
        }
    }
    tbl
}
