#' Check API health status
#'
#' Queries the `/health` endpoint and returns the status of the API
#' and its database connection.
#'
#' @return A 1-row tibble with columns `status`, `environment`, `database`.
#' @export
#' @examples
#' \dontrun{
#' get_health()
#' }
get_health <- function() {
    if (edb_backend_is_sqlite()) edb_warn_api_fallback("get_health()")
    json <- edb_get("/health")
    parse_single(json)
}
