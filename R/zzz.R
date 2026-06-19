# Package-level environment for mutable state
.eleccionesdb_env <- new.env(parent = emptyenv())

 .onLoad <- function(libname, pkgname) {
    url <- Sys.getenv("ELECCIONESDB_URL", unset = "https://api.spainelectoralproject.com/")
    # Strip trailing slash
    url <- sub("/+$$", "", url)
    .eleccionesdb_env$base_url <- url
    .eleccionesdb_env$backend <- "api"
    .eleccionesdb_env$sqlite_path <- NULL
}
