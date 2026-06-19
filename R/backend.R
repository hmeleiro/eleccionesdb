#' Configure the EleccionesDB data backend
#'
#' Selects whether public query functions read from the remote API or from a
#' local SQLite snapshot. The setting applies only to the current R session.
#'
#' @param backend One of `"api"` or `"sqlite"`.
#' @param path Path to `eleccionesdb.sqlite`. When omitted, [edb_sqlite_path()]
#'   is used.
#' @return The previous backend configuration, invisibly.
#' @export
#' @examples
#' \dontrun{
#' edb_download_sqlite()
#' edb_set_backend("sqlite")
#' get_elecciones(tipo_eleccion = "G")
#' edb_set_backend("api")
#' }
edb_set_backend <- function(backend = c("api", "sqlite"), path = NULL) {
    backend <- match.arg(backend)
    old <- edb_get_backend()

    if (identical(backend, "sqlite")) {
        path <- path %||% edb_sqlite_path()
        path <- path.expand(path)
        if (!file.exists(path)) {
            cli::cli_abort(c(
                "x" = "No se encuentra la base SQLite en {.file {path}}.",
                "i" = "Descargala con {.code edb_download_sqlite()} o indica {.arg path}."
            ))
        }
        edb_sqlite_validate(path, quick = FALSE)
        .eleccionesdb_env$sqlite_path <- normalizePath(path, winslash = "/", mustWork = TRUE)
    } else {
        .eleccionesdb_env$sqlite_path <- NULL
    }

    .eleccionesdb_env$backend <- backend
    invisible(old)
}

#' Inspect the active EleccionesDB backend
#'
#' @return A named list with `backend` and `path`.
#' @export
edb_get_backend <- function() {
    list(
        backend = .eleccionesdb_env$backend %||% "api",
        path = .eleccionesdb_env$sqlite_path %||% NULL
    )
}

#' Default path for the EleccionesDB SQLite snapshot
#'
#' @return A platform-appropriate file path.
#' @export
edb_sqlite_path <- function() {
    file.path(tools::R_user_dir("eleccionesdb", "data"), "eleccionesdb.sqlite")
}

#' @noRd
edb_backend_is_sqlite <- function() {
    identical(.eleccionesdb_env$backend %||% "api", "sqlite")
}

#' @noRd
edb_sqlite_active_path <- function() {
    path <- .eleccionesdb_env$sqlite_path
    if (is.null(path) || !file.exists(path)) {
        cli::cli_abort(c(
            "x" = "El backend SQLite esta activo, pero su archivo no esta disponible.",
            "i" = "Vuelve a configurarlo con {.code edb_set_backend('sqlite', path = ...)}."
        ))
    }
    path
}

#' @noRd
edb_require_sqlite <- function() {
    missing <- c("DBI", "RSQLite")[!vapply(
        c("DBI", "RSQLite"), requireNamespace, logical(1), quietly = TRUE
    )]
    if (length(missing) > 0L) {
        cli::cli_abort(c(
            "x" = "El backend SQLite requiere paquetes opcionales.",
            "i" = "Instalalos con {.code install.packages(c('DBI', 'RSQLite'))}."
        ))
    }
    invisible(TRUE)
}

#' @noRd
edb_warn_api_fallback <- function(operation) {
    cli::cli_warn(c(
        "!" = "{operation} no esta disponible en el backend SQLite; se usara la API.",
        "i" = "La llamada puede requerir conexion y API key."
    ))
}
