#' List political parties with optional filters
#'
#' Returns a paginated list of parties. Supports partial search by
#' abbreviation (`siglas`) and full name (`denominacion`), and filtering
#' by recode group.
#'
#' @param siglas Character. Partial search by party abbreviation,
#'   case-insensitive (e.g. `"psoe"`). Optional.
#' @param denominacion Character. Partial search by full party name,
#'   case-insensitive (e.g. `"socialista"`). Optional.
#' @param partido_recode_id Integer vector. Filter by recode/group ID(s). Optional.
#' @param limit Integer. Maximum records per page (1-500, default 50).
#' @param skip Integer. Records to skip (default 0).
#' @param all_pages Logical. If `TRUE`, fetches all pages. Default `FALSE`.

#' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
#' @return A tibble with columns: `id`, `siglas`, `denominacion`,
#'   `partido_recode_id`.
#' @export
#' @examples
#' \dontrun{
#' # Search for PSOE-related parties
#' get_partidos(siglas = "psoe")
#'
#' # All parties in a specific recode group
#' get_partidos(partido_recode_id = 80, all_pages = TRUE)
#'
#' # Usar clave explícita solo para esta llamada
#' get_partidos(siglas = "psoe", api_key = "OTRA_CLAVE")
#' }
get_partidos <- function(siglas = NULL, denominacion = NULL,
                         partido_recode_id = NULL,
                         limit = 50L, skip = 0L, all_pages = FALSE,
                         api_key = NULL) {
    if (edb_backend_is_sqlite()) {
        return(sqlite_get_partidos(
            siglas, denominacion, partido_recode_id, limit, skip, all_pages
        ))
    }
    params <- list(
        siglas = siglas,
        denominacion = denominacion,
        partido_recode_id = partido_recode_id
    )
    edb_paginated_get(
        path = "/v1/partidos",
        params = params,
        limit = limit,
        skip = skip,
        all_pages = all_pages,
        api_key = api_key
    )
}

#' Get a single party by ID
#'
#' Returns the full detail of a party, including its recode/group
#' information flattened into prefixed columns.
#'
#' When the party has no recode (`partido_recode_id` is `NA`), the
#' recode columns will contain `NA`.
#'
#' @param partido_id Integer. The party ID.
#' @return A 1-row tibble with columns: `id`, `siglas`, `denominacion`,
#'   `partido_recode_id`, `recode_id`, `recode_partido_recode`,
#'   `recode_agrupacion`, `recode_color`.
#' @export
#' @examples
#' \dontrun{
#' # Party with recode
#' get_partido(5082)
#'
#' # Party without recode (PACMA)
#' get_partido(11911)
#' }
get_partido <- function(partido_id) {
    if (edb_backend_is_sqlite()) return(sqlite_get_partido(partido_id))
    json <- edb_get(paste0("/v1/partidos/", partido_id))
    tbl <- parse_single(json)
    tbl <- flatten_nested(tbl, "recode", "recode")
    tbl
}

#' List party recode/groups with optional filter
#'
#' Returns a paginated list of party recodes (groupings/families).
#'
#' @param agrupacion Character. Partial search by grouping name,
#'   case-insensitive (e.g. `"PCE/IU"`). Optional.
#' @param limit Integer. Maximum records per page (1-500, default 50).
#' @param skip Integer. Records to skip (default 0).
#' @param all_pages Logical. If `TRUE`, fetches all pages. Default `FALSE`.
#' @return A tibble with columns: `id`, `partido_recode`, `agrupacion`, `color`.
#' @export
#' @examples
#' \dontrun{
#' # All recode groups
#' get_partidos_recode(all_pages = TRUE)
#'
#' # Search by grouping
#' get_partidos_recode(agrupacion = "PCE/IU")
#' }
get_partidos_recode <- function(agrupacion = NULL, limit = 50L, skip = 0L,
                                all_pages = FALSE) {
    if (edb_backend_is_sqlite()) {
        return(sqlite_get_partidos_recode(agrupacion, limit, skip, all_pages))
    }
    params <- list(agrupacion = agrupacion)
    edb_paginated_get(
        path = "/v1/partidos-recode",
        params = params,
        limit = limit,
        skip = skip,
        all_pages = all_pages
    )
}

#' Get a single party recode/group by ID
#'
#' Returns the recode detail and its list of associated parties.
#' Because a recode group can contain thousands of parties, this function
#' returns a named list instead of a single tibble.
#'
#' @param partido_recode_id Integer. The recode group ID.
#' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
#' @return A named list with two elements:
#'   \describe{
#'     \item{`recode`}{A 1-row tibble with `id`, `partido_recode`,
#'       `agrupacion`, `color`.}
#'     \item{`partidos`}{A tibble of associated parties with `id`, `siglas`,
#'       `denominacion`, `partido_recode_id`. Can contain hundreds/thousands
#'       of rows.}
#'   }
#' @export
#' @examples
#' \dontrun{
#' result <- get_partido_recode(47)
#' result$recode
#' result$partidos
#' nrow(result$partidos) # Can be ~2200 for IU
#' }
get_partido_recode <- function(partido_recode_id, api_key = NULL) {
    if (edb_backend_is_sqlite()) {
        return(sqlite_get_partido_recode(partido_recode_id))
    }
    json <- edb_get(paste0("/v1/partidos-recode/", partido_recode_id), api_key = api_key)

    partidos_data <- json[["partidos"]] %||% list()
    json[["partidos"]] <- NULL

    recode_tbl <- parse_single(json)
    partidos_tbl <- safe_tibble(partidos_data)
    list(
        recode = recode_tbl,
        partidos = partidos_tbl
    )
}
