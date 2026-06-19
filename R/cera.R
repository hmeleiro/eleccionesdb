#' List CERA (overseas vote) summaries
#'
#' Returns paginated summaries for the overseas electorate (CERA — Censo
#' de Espanoles Residentes Ausentes).
#'
#' @param year Character vector. Filter by year(s). Optional.
#' @param tipo_eleccion Character vector. Filter by election type code(s).
#'   Valid values: `"A"` (Autonomicas), `"E"` (Europeas), `"G"` (Congreso),
#'   `"L"` (Locales), `"S"` (Senado). Optional.
#' @param ... Arguments after `...` must be named.
#' @param eleccion_id Integer vector. Filter by election ID(s). Optional.
#' @param territorio_id Integer vector. Filter by territory ID(s). Optional.
#' @param limit Integer. Maximum records per page (1-500, default 50).
#' @param skip Integer. Records to skip (default 0).
#' @param all_pages Logical. If `TRUE`, fetches all pages. Default `FALSE`.
#' @param denormalize Logical. If `TRUE`, adds descriptive columns next to
#'   ID columns: `eleccion_descripcion` (after `eleccion_id`) and
#'   `territorio_nombre` (after `territorio_id`). Requires additional API
#'   calls. Default `FALSE`.
#' @param clean Logical. If `TRUE`, removes ID and slug columns from the
#'   result. Defaults to the value of `denormalize`.
#' @return A tibble with columns: `id`, `eleccion_id`, `territorio_id`,
#'   `censo_ine`, `votos_validos`, `abstenciones`, `votos_blancos`,
#'   `votos_nulos`. When `denormalize = TRUE`, additional columns
#'   `eleccion_descripcion` and `territorio_nombre` are inserted after
#'   their corresponding ID columns. When `clean = TRUE`, ID and slug
#'   columns are removed.
#' @export
#' @examples
#' \dontrun{
#' get_cera_resumen(tipo_eleccion = "G", year = "2019")
#'
#' # With denormalized names (clean by default)
#' get_cera_resumen(tipo_eleccion = "G", denormalize = TRUE)
#' }
get_cera_resumen <- function(year = NULL, tipo_eleccion = NULL,
                             ...,
                             eleccion_id = NULL, territorio_id = NULL,
                             limit = 50L, skip = 0L, all_pages = FALSE,
                             denormalize = FALSE,
                             clean = denormalize,
                             api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    params <- list(
        eleccion_id = eleccion_id,
        territorio_id = territorio_id,
        year = year,
        tipo_eleccion = tipo_eleccion
    )
    if (edb_backend_is_sqlite()) {
        tbl <- sqlite_get_totales(
            eleccion_id = eleccion_id, territorio_id = territorio_id,
            year = year, tipo_eleccion = tipo_eleccion,
            tipo_territorio = "cera", limit = limit, skip = skip,
            all_pages = all_pages
        )
    } else {
        tbl <- edb_paginated_get(
            path = "/v1/resultados/cera/resumen",
            params = params,
            limit = limit,
            skip = skip,
            all_pages = all_pages,
            api_key = api_key
        )
    }
    if (denormalize) {
        tbl <- denormalize_tbl(tbl)
    }
    if (clean) {
        tbl <- clean_result_tbl(tbl)
    }
    sort_result_tbl(tbl)
}

#' List CERA (overseas) per-party votes
#'
#' Returns paginated per-party votes for the overseas electorate.
#'
#' @param year Character vector. Filter by year(s). Optional.
#' @param tipo_eleccion Character vector. Filter by election type code(s).
#'   Valid values: `"A"` (Autonomicas), `"E"` (Europeas), `"G"` (Congreso),
#'   `"L"` (Locales), `"S"` (Senado). Optional.
#' @param ... Arguments after `...` must be named.
#' @param eleccion_id Integer vector. Filter by election ID(s). Optional.
#' @param territorio_id Integer vector. Filter by territory ID(s). Optional.
#' @param partido_id Integer vector. Filter by party ID(s). Optional.
#' @param limit Integer. Maximum records per page (1-500, default 50).
#' @param skip Integer. Records to skip (default 0).
#' @param all_pages Logical. If `TRUE`, fetches all pages. Default `FALSE`.
#' @param denormalize Logical. If `TRUE`, adds descriptive columns next to
#'   ID columns: `eleccion_descripcion` (after `eleccion_id`),
#'   `territorio_nombre` (after `territorio_id`), and `partido_nombre`
#'   (after `partido_id`). Requires additional lookups. Default `FALSE`.
#' @param use_recode Logical. If `TRUE` and `denormalize = TRUE`, the
#'   `partido_nombre` column uses the recode group name (`agrupacion`)
#'   instead of the party abbreviation (`siglas`). Falls back to `siglas`
#'   when the party has no recode. Default `FALSE`.
#' @param clean Logical. If `TRUE`, removes ID and slug columns from the
#'   result. Defaults to the value of `denormalize`.
#' @return A tibble with columns: `id`, `eleccion_id`, `territorio_id`,
#'   `partido_id`, `votos`. When `denormalize = TRUE`, additional columns
#'   `eleccion_descripcion`, `territorio_nombre`, and `partido_nombre`
#'   are inserted after their corresponding ID columns. When `clean = TRUE`,
#'   ID and slug columns are removed.
#' @export
#' @examples
#' \dontrun{
#' get_cera_votos(tipo_eleccion = "G", year = "2019")
#'
#' # With denormalized names using recode grouping
#' get_cera_votos(
#'     tipo_eleccion = "G",
#'     denormalize = TRUE, use_recode = TRUE
#' )
#' }
get_cera_votos <- function(year = NULL, tipo_eleccion = NULL,
                           ...,
                           eleccion_id = NULL, territorio_id = NULL,
                           partido_id = NULL,
                           limit = 50L, skip = 0L, all_pages = FALSE,
                           denormalize = FALSE, use_recode = FALSE,
                           clean = denormalize,
                           api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    params <- list(
        eleccion_id = eleccion_id,
        territorio_id = territorio_id,
        partido_id = partido_id,
        year = year,
        tipo_eleccion = tipo_eleccion
    )
    if (edb_backend_is_sqlite()) {
        tbl <- sqlite_get_votos(
            eleccion_id = eleccion_id, territorio_id = territorio_id,
            partido_id = partido_id, year = year,
            tipo_eleccion = tipo_eleccion, tipo_territorio = "cera",
            limit = limit, skip = skip, all_pages = all_pages
        )
    } else {
        tbl <- edb_paginated_get(
            path = "/v1/resultados/cera/votos",
            params = params,
            limit = limit,
            skip = skip,
            all_pages = all_pages,
            api_key = api_key
        )
    }
    if (denormalize) {
        tbl <- denormalize_tbl(tbl, use_recode = use_recode)
    }
    if (clean) {
        tbl <- clean_result_tbl(tbl)
    }
    sort_result_tbl(tbl)
}
