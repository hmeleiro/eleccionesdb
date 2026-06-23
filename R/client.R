#' Set the EleccionesDB API key
#'
#' Guarda la clave de API globalmente para todas las peticiones protegidas.
#' Por defecto, la clave se almacena en la opción de R y en la variable de entorno
#' para la sesión actual. Si `persist = TRUE`, también se añade a tu archivo `.Renviron`
#' para que esté disponible en futuras sesiones.
#'
#' @param key Cadena de texto con la API key.
#' @param persist Lógico. Si `TRUE`, guarda la clave en tu `.Renviron` de usuario.
#' @return Invisiblemente, la clave anterior (si existía).
#' @export
#' @examples
#' \dontrun{
#' edb_set_api_key("TU_API_KEY")
#' }
edb_set_api_key <- function(key, persist = FALSE) {
    if (!is.character(key) || length(key) != 1 || nchar(key) == 0) {
        cli::cli_abort("{.arg key} debe ser una cadena de texto no vac\u00eda.")
    }
    old <- getOption("eleccionesdb.api_key", NULL)
    options(eleccionesdb.api_key = key)
    Sys.setenv(ELECCIONESDB_API_KEY = key)
    .eleccionesdb_env$api_key <- key
    if (isTRUE(persist)) {
        renv_path <- path.expand("~/.Renviron")
        if (file.exists(renv_path)) {
            lines <- readLines(renv_path, warn = FALSE)
            # Elimina líneas previas de la clave
            lines <- lines[!grepl("^ELECCIONESDB_API_KEY=", lines)]
        } else {
            lines <- character()
        }
        lines <- c(lines, paste0("ELECCIONESDB_API_KEY=", key))
        writeLines(lines, renv_path)
        cli::cli_alert_success("Clave guardada en {.file ~/.Renviron}. Reinicia R para que est\u00e9 disponible globalmente.")
    }
    invisible(old)
}

#' Get the current EleccionesDB API key
#'
#' Recupera la clave de API desde la opción, variable de entorno o entorno interno.
#' @return Cadena de texto con la clave, o NULL si no está definida.
#' @export
edb_get_api_key <- function() {
    key <- getOption("eleccionesdb.api_key", NULL)
    if (!is.null(key) && nchar(key) > 0) {
        return(key)
    }
    key <- Sys.getenv("ELECCIONESDB_API_KEY", unset = NA)
    if (!is.na(key) && nchar(key) > 0) {
        return(key)
    }
    key <- .eleccionesdb_env$api_key
    if (!is.null(key) && nchar(key) > 0) {
        return(key)
    }
    NULL
}
#' Set the EleccionesDB API base URL
#'
#' @param url Character string with the base URL (e.g. `"https://data.hmeleiro.com/"`).
#' @return The previous base URL, invisibly.
#' @export
#' @examples
#' \dontrun{
#' edb_set_base_url("http://my-server:8000")
#' }
edb_set_base_url <- function(url) {
    if (!is.character(url) || length(url) != 1 || nchar(url) == 0) {
        cli::cli_abort("{.arg url} must be a non-empty character string.")
    }
    url <- sub("/+$", "", url)
    old <- .eleccionesdb_env$base_url

    .eleccionesdb_env$base_url <- url
    invisible(old)
}

#' Get the current EleccionesDB API base URL
#'
#' @return Character string with the current base URL.
#' @export
#' @examples
#' edb_get_base_url()
edb_get_base_url <- function() {
    .eleccionesdb_env$base_url
}

#' Build a base httr2 request for the API
#'
#' @param path Character. The API path (e.g. `"/v1/elecciones"`).
#' @return An httr2 request object.
#' @noRd
edb_base_request <- function(path, api_key = NULL, require_key = TRUE) {
    req <- httr2::request(.eleccionesdb_env$base_url) |>
        httr2::req_url_path_append(path) |>
        httr2::req_headers("Accept" = "application/json") |>
        httr2::req_user_agent("eleccionesdb/0.1.0")
    # Determinar si el endpoint requiere clave
    is_protected <- grepl("^/v1/", path) && !grepl("^/v1/auth/", path)
    if (is_protected && isTRUE(require_key)) {
        key <- api_key %||% edb_get_api_key()
        if (is.null(key) || nchar(key) == 0) {
            cli::cli_abort(c(
                "x" = "Este endpoint requiere autenticaci\u00f3n por API key.",
                "i" = "Registra tu clave con edb_set_api_key('TU_API_KEY') o p\u00e1sala como argumento."
            ))
        }
        req <- httr2::req_headers(req, "X-API-Key" = key)
    } else if (!is.null(api_key)) {
        req <- httr2::req_headers(req, "X-API-Key" = api_key)
    }
    req
}
