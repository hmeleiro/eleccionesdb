#' List all election types
#'
#' Retrieves the catalogue of election types. This is a small, non-paginated
#' endpoint that returns all types directly as an array.
#'
#' @return A tibble with columns `codigo` and `descripcion`.
#' @export
#' @examples
#' \dontrun{
#' get_tipos_eleccion()
#' # # A tibble: 5 x 2
#' #   codigo descripcion
#' #   <chr>  <chr>
#' # 1 A      Autonomicas
#' # 2 E      Europeas
#' # 3 G      Congreso
#' # 4 L      Locales
#' # 5 S      Senado
#' }
get_tipos_eleccion <- function(api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    if (edb_backend_is_sqlite()) return(sqlite_get_tipos_eleccion())
    json <- edb_get("/v1/tipos-eleccion", api_key = api_key)
    parse_array(json)
}

#' Get a single election type by code
#'
#' @param codigo Character. The election type code. Valid values: `"A"`
#'   (Autonomicas), `"E"` (Europeas), `"G"` (Congreso), `"L"` (Locales),
#'   `"S"` (Senado).
#' @return A 1-row tibble with columns `codigo` and `descripcion`.
#' @export
#' @examples
#' \dontrun{
#' get_tipo_eleccion("G")
#' }
get_tipo_eleccion <- function(codigo, api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    if (edb_backend_is_sqlite()) return(sqlite_get_tipo_eleccion(codigo))
    json <- edb_get(paste0("/v1/tipos-eleccion/", codigo), api_key = api_key)
    parse_single(json)
}

#' List elections with optional filters
#'
#' Returns a paginated list of elections. Use `all_pages = TRUE` to retrieve
#' all matching records automatically.
#'
#' @param tipo_eleccion Character vector. Filter by election type code(s).
#'   Valid values: `"A"` (Autonomicas), `"E"` (Europeas), `"G"` (Congreso),
#'   `"L"` (Locales), `"S"` (Senado). Optional.
#' @param year Character vector. Filter by year (e.g. `"2019"`,
#'   `c("2019", "2023")`). Optional.
#' @param mes Character vector. Filter by month with leading zero
#'   (e.g. `"04"`, `"11"`). Optional.
#' @param ambito Character vector. Filter by scope (e.g. `"Nacional"`,
#'   `"Autonomico"`). Optional.
#' @param limit Integer. Maximum records to return per page (1-500, default 50).
#' @param skip Integer. Records to skip (default 0).
#' @param all_pages Logical. If `TRUE`, fetches all pages automatically.
#'   Default `FALSE`.
#' @return A tibble with columns: `id`, `tipo_eleccion`, `year`, `mes`, `dia`,
#'   `fecha` (Date), `descripcion`, `ambito`, `slug`.
#'
#'   The tibble has an `"edb_total"` attribute with the total record count.
#' @export
#' @examples
#' \dontrun{
#' # All general elections
#' get_elecciones(tipo_eleccion = "G")
#'
#' # General elections in 2019
#' get_elecciones(tipo_eleccion = "G", year = "2019")
#'
#' # Fetch all elections (all pages)
#' get_elecciones(all_pages = TRUE)
#' }
get_elecciones <- function(tipo_eleccion = NULL, year = NULL, mes = NULL,
                           ambito = NULL, limit = 50L, skip = 0L,
                           all_pages = FALSE, api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    if (edb_backend_is_sqlite()) {
        return(sqlite_get_elecciones(
            tipo_eleccion, year, mes, ambito, limit, skip, all_pages
        ))
    }
    params <- list(
        tipo_eleccion = tipo_eleccion,
        year = year,
        mes = mes,
        ambito = ambito
    )
    edb_paginated_get(
        path = "/v1/elecciones",
        params = params,
        limit = limit,
        skip = skip,
        all_pages = all_pages,
        parse_fn = coerce_dates,
        api_key = api_key
    )
}

#' Get a single election by ID
#'
#' Returns the full detail of an election, including the election type
#' as expanded columns (`tipo_codigo`, `tipo_descripcion`).
#'
#' @param eleccion_id Integer. The election ID.
#' @return A 1-row tibble with columns: `id`, `tipo_eleccion`, `year`, `mes`,
#'   `dia`, `fecha` (Date), `codigo_ccaa`, `numero_vuelta`, `descripcion`,
#'   `ambito`, `slug`, `tipo_codigo`, `tipo_descripcion`.
#' @export
#' @examples
#' \dontrun{
#' get_eleccion(208)
#' }
get_eleccion <- function(eleccion_id, api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    if (edb_backend_is_sqlite()) return(sqlite_get_eleccion(eleccion_id))
    json <- edb_get(paste0("/v1/elecciones/", eleccion_id), api_key = api_key)
    tbl <- parse_single(json)
    tbl <- flatten_nested(tbl, "tipo", "tipo")
    tbl <- coerce_dates(tbl)
    tbl
}
