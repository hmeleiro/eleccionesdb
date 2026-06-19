#' List territories with optional filters
#'
#' Returns a paginated list of territories. Supports filtering by type,
#' administrative codes, and partial name search.
#'
#' @param tipo Character vector. Filter by territory type. Valid values:
#'   `"ccaa"`, `"provincia"`, `"municipio"`, `"distrito"`, `"seccion"`,
#'   `"circunscripcion"`, `"cera"`. Optional.
#' @param codigo_ccaa Character vector. Filter by autonomous community INE
#'   code(s) (e.g. `"01"`, `"13"`). Optional.
#' @param codigo_provincia Character vector. Filter by province INE code(s)
#'   (e.g. `"28"`, `"08"`). Optional.
#' @param codigo_municipio Character vector. Filter by municipality INE
#'   code(s). Optional.
#' @param codigo_circunscripcion Character vector. Filter by constituency code. Optional.
#' @param nombre Character. Partial name search, case-insensitive
#'   (e.g. `"madrid"`). Optional.
#' @param limit Integer. Maximum records per page (1-500, default 50).
#' @param skip Integer. Records to skip (default 0).
#' @param all_pages Logical. If `TRUE`, fetches all pages. Default `FALSE`.
#' @return A tibble with columns: `id`, `tipo`, `nombre`, `codigo_completo`,
#'   `codigo_ccaa`, `codigo_provincia`.
#' @export
#' @examples
#' \dontrun{
#' # All autonomous communities
#' get_territorios(tipo = "ccaa")
#'
#' # Search by name
#' get_territorios(nombre = "madrid", tipo = "provincia")
#'
#' # Provinces in Andalucia (codigo_ccaa = "01")
#' get_territorios(tipo = "provincia", codigo_ccaa = "01", all_pages = TRUE)
#' }
get_territorios <- function(tipo = NULL, codigo_ccaa = NULL,
                            codigo_provincia = NULL, codigo_municipio = NULL,
                            codigo_circunscripcion = NULL, nombre = NULL,
                            limit = 50L, skip = 0L, all_pages = FALSE, api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    if (edb_backend_is_sqlite()) {
        return(sqlite_get_territorios(
            tipo, codigo_ccaa, codigo_provincia, codigo_municipio,
            codigo_circunscripcion, nombre, limit, skip, all_pages
        ))
    }
    params <- list(
        tipo = tipo,
        codigo_ccaa = codigo_ccaa,
        codigo_provincia = codigo_provincia,
        codigo_municipio = codigo_municipio,
        codigo_circunscripcion = codigo_circunscripcion,
        nombre = nombre
    )
    edb_paginated_get(
        path = "/v1/territorios",
        params = params,
        limit = limit,
        skip = skip,
        all_pages = all_pages,
        api_key = api_key
    )
}

#' Get a single territory by ID
#'
#' Returns the full detail of a territory with all administrative codes.
#'
#' @param territorio_id Integer. The territory ID.
#' @return A 1-row tibble with columns: `id`, `tipo`, `codigo_ccaa`,
#'   `codigo_provincia`, `codigo_municipio`, `codigo_distrito`,
#'   `codigo_seccion`, `codigo_circunscripcion`, `nombre`,
#'   `codigo_completo`, `parent_id`.
#' @export
#' @examples
#' \dontrun{
#' get_territorio(1) # Andalucia
#' get_territorio(63) # Madrid (province)
#' }
get_territorio <- function(territorio_id, api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    if (edb_backend_is_sqlite()) return(sqlite_get_territorio(territorio_id))
    json <- edb_get(paste0("/v1/territorios/", territorio_id), api_key = api_key)
    parse_single(json)
}

#' List child territories (hierarchical navigation)
#'
#' Returns the direct children of a territory. For example, provinces
#' within an autonomous community, or municipalities within a province.
#'
#' @param territorio_id Integer. The parent territory ID.
#' @param limit Integer. Maximum records per page (1-500, default 50).
#' @param skip Integer. Records to skip (default 0).
#' @param all_pages Logical. If `TRUE`, fetches all pages. Default `FALSE`.
#' @return A tibble with columns: `id`, `tipo`, `nombre`, `codigo_completo`,
#'   `codigo_ccaa`, `codigo_provincia`.
#' @export
#' @examples
#' \dontrun{
#' # Provinces in Andalucia (territory ID 1)
#' get_territorio_hijos(1, all_pages = TRUE)
#' }
get_territorio_hijos <- function(territorio_id, limit = 50L, skip = 0L,
                                 all_pages = FALSE, api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    if (edb_backend_is_sqlite()) {
        return(sqlite_get_territorios(
            limit = limit, skip = skip, all_pages = all_pages,
            parent_id = territorio_id
        ))
    }
    edb_paginated_get(
        path = paste0("/v1/territorios/", territorio_id, "/hijos"),
        limit = limit,
        skip = skip,
        all_pages = all_pages,
        api_key = api_key
    )
}
