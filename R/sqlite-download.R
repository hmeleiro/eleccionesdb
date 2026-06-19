.edb_sqlite_manifest_url <- paste0(
    "https://data.spainelectoralproject.com/eleccionesdb-etl/descargas/",
    "eleccionesdb_sqlite.json"
)

#' Check whether a newer SQLite snapshot is available
#'
#' Downloads only the small remote manifest and compares it with the locally
#' installed snapshot.
#'
#' @param path Destination SQLite path. Defaults to [edb_sqlite_path()].
#' @return A one-row tibble describing the local and remote versions.
#' @export
edb_check_sqlite_update <- function(path = NULL) {
    path <- path.expand(path %||% edb_sqlite_path())
    remote <- edb_sqlite_remote_manifest()
    local <- edb_sqlite_local_manifest(path)
    local_hash <- local[["database_sha256"]] %||% NA_character_

    if (file.exists(path) && is.na(local_hash)) {
        local_hash <- edb_sha256(path)
    }

    tibble::tibble(
        path = path,
        installed = file.exists(path),
        local_sha256 = local_hash,
        remote_sha256 = remote[["database_sha256"]],
        generated_at = remote[["generated_at"]],
        archive_size = as.numeric(remote[["archive_size"]]),
        database_size = as.numeric(remote[["database_size"]]),
        schema_version = as.integer(remote[["schema_version"]]),
        update_available = !file.exists(path) ||
            is.na(local_hash) || !identical(local_hash, remote[["database_sha256"]])
    )
}

#' Download or update the EleccionesDB SQLite snapshot
#'
#' The archive and extracted database are verified with SHA-256 checksums. The
#' installed database is replaced only after all validation succeeds.
#'
#' @param path Destination SQLite path. Defaults to [edb_sqlite_path()].
#' @param force Download even when the installed checksum is current.
#' @return The installed SQLite path, invisibly.
#' @export
edb_download_sqlite <- function(path = NULL, force = FALSE) {
    path <- path.expand(path %||% edb_sqlite_path())
    if (!is.logical(force) || length(force) != 1L || is.na(force)) {
        cli::cli_abort("{.arg force} debe ser TRUE o FALSE.")
    }
    edb_require_sqlite()
    edb_require_digest()
    if (!requireNamespace("jsonlite", quietly = TRUE)) {
        cli::cli_abort(c(
            "x" = "La descarga SQLite requiere el paquete {.pkg jsonlite}.",
            "i" = "Instalalo con {.code install.packages('jsonlite')}."
        ))
    }

    manifest <- edb_sqlite_remote_manifest()
    local <- edb_sqlite_local_manifest(path)
    local_hash <- local[["database_sha256"]] %||% NA_character_
    if (file.exists(path) && is.na(local_hash)) local_hash <- edb_sha256(path)

    if (!force && file.exists(path) &&
        identical(local_hash, manifest[["database_sha256"]])) {
        cli::cli_alert_success("La base SQLite ya esta actualizada.")
        return(invisible(normalizePath(path, winslash = "/", mustWork = TRUE)))
    }

    dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
    zip_tmp <- tempfile("eleccionesdb_", tmpdir = dirname(path), fileext = ".zip")
    extract_dir <- tempfile("eleccionesdb_extract_", tmpdir = dirname(path))
    dir.create(extract_dir)
    on.exit(unlink(c(zip_tmp, extract_dir), recursive = TRUE, force = TRUE), add = TRUE)

    archive_size <- as.numeric(manifest[["archive_size"]])
    cli::cli_inform("Descargando snapshot SQLite ({sprintf('%.1f MB', archive_size / 1024^2)})...")
    edb_download_file(manifest[["url"]], zip_tmp)

    edb_assert_file_size(zip_tmp, archive_size, "ZIP")
    edb_assert_sha256(zip_tmp, manifest[["archive_sha256"]], "ZIP")

    listing <- utils::unzip(zip_tmp, list = TRUE)
    expected_name <- manifest[["database_filename"]]
    if (nrow(listing) != 1L || !identical(listing[["Name"]], expected_name) ||
        !identical(basename(expected_name), expected_name)) {
        cli::cli_abort("El ZIP no contiene exactamente {.file {expected_name}}.")
    }
    utils::unzip(zip_tmp, files = expected_name, exdir = extract_dir)
    candidate <- file.path(extract_dir, expected_name)

    edb_assert_file_size(candidate, as.numeric(manifest[["database_size"]]), "SQLite")
    edb_assert_sha256(candidate, manifest[["database_sha256"]], "SQLite")
    edb_sqlite_validate(candidate, quick = TRUE)
    edb_install_sqlite(candidate, path, manifest)

    cli::cli_alert_success("Base SQLite instalada en {.file {path}}.")
    invisible(normalizePath(path, winslash = "/", mustWork = TRUE))
}

#' @noRd
edb_sqlite_remote_manifest <- function() {
    resp <- httr2::request(.edb_sqlite_manifest_url) |>
        httr2::req_user_agent("eleccionesdb-r/0.1.0") |>
        httr2::req_perform(error_call = rlang::caller_env())
    manifest <- httr2::resp_body_json(resp, simplifyVector = TRUE)
    edb_validate_manifest(manifest)
}

#' @noRd
edb_download_file <- function(url, path) {
    req <- httr2::request(url) |>
        httr2::req_user_agent("eleccionesdb-r/0.1.0") |>
        httr2::req_progress()
    httr2::req_perform(req, path = path, error_call = rlang::caller_env())
    invisible(path)
}

#' @noRd
edb_validate_manifest <- function(manifest) {
    required <- c(
        "schema_version", "generated_at", "url", "archive_size",
        "archive_sha256", "database_filename", "database_size",
        "database_sha256"
    )
    missing <- setdiff(required, names(manifest))
    if (length(missing) > 0L) {
        cli::cli_abort("El manifiesto SQLite no contiene: {paste(missing, collapse = ', ')}.")
    }
    if (!identical(as.integer(manifest[["schema_version"]]), 1L)) {
        cli::cli_abort("Version de esquema SQLite no compatible: {manifest[['schema_version']]}.")
    }
    hashes <- c(manifest[["archive_sha256"]], manifest[["database_sha256"]])
    if (any(!grepl("^[0-9a-fA-F]{64}$", hashes))) {
        cli::cli_abort("El manifiesto SQLite contiene checksums SHA-256 invalidos.")
    }
    manifest
}

#' @noRd
edb_sqlite_manifest_path <- function(path) paste0(path, ".json")

#' @noRd
edb_sqlite_local_manifest <- function(path) {
    manifest_path <- edb_sqlite_manifest_path(path)
    if (!file.exists(manifest_path) || !requireNamespace("jsonlite", quietly = TRUE)) {
        return(list())
    }
    tryCatch(
        jsonlite::read_json(manifest_path, simplifyVector = TRUE),
        error = function(e) list()
    )
}

#' @noRd
edb_require_digest <- function() {
    if (!requireNamespace("digest", quietly = TRUE)) {
        cli::cli_abort(c(
            "x" = "La verificacion SHA-256 requiere el paquete {.pkg digest}.",
            "i" = "Instalalo con {.code install.packages('digest')}."
        ))
    }
}

#' @noRd
edb_sha256 <- function(path) {
    edb_require_digest()
    tolower(digest::digest(file = path, algo = "sha256", serialize = FALSE))
}

#' @noRd
edb_assert_sha256 <- function(path, expected, label) {
    actual <- edb_sha256(path)
    if (!identical(actual, tolower(expected))) {
        cli::cli_abort("El checksum SHA-256 de {label} no coincide con el manifiesto.")
    }
    invisible(TRUE)
}

#' @noRd
edb_assert_file_size <- function(path, expected, label) {
    actual <- unname(file.info(path)[["size"]])
    if (is.na(actual) || !identical(as.numeric(actual), as.numeric(expected))) {
        cli::cli_abort("El tamano de {label} no coincide con el manifiesto.")
    }
    invisible(TRUE)
}

#' @noRd
edb_install_sqlite <- function(candidate, path, manifest) {
    if (!requireNamespace("jsonlite", quietly = TRUE)) {
        cli::cli_abort("Guardar el manifiesto local requiere el paquete {.pkg jsonlite}.")
    }
    manifest_path <- edb_sqlite_manifest_path(path)
    manifest_tmp <- tempfile("manifest_", tmpdir = dirname(path), fileext = ".json")
    jsonlite::write_json(manifest, manifest_tmp, auto_unbox = TRUE, pretty = TRUE)

    backup <- tempfile("eleccionesdb_backup_", tmpdir = dirname(path), fileext = ".sqlite")
    manifest_backup <- tempfile("manifest_backup_", tmpdir = dirname(path), fileext = ".json")
    had_old <- file.exists(path)
    had_manifest <- file.exists(manifest_path)
    if (had_old && !file.rename(path, backup)) {
        cli::cli_abort("No se pudo preparar la sustitucion de {.file {path}}.")
    }
    if (had_manifest && !file.rename(manifest_path, manifest_backup)) {
        if (had_old) file.rename(backup, path)
        cli::cli_abort("No se pudo preparar la sustitucion del manifiesto local.")
    }
    installed <- FALSE
    on.exit({
        if (!installed && file.exists(path)) unlink(path, force = TRUE)
        if (!installed && had_old && file.exists(backup)) file.rename(backup, path)
        if (!installed && file.exists(manifest_path)) unlink(manifest_path, force = TRUE)
        if (!installed && had_manifest && file.exists(manifest_backup)) {
            file.rename(manifest_backup, manifest_path)
        }
        if (installed && file.exists(backup)) unlink(backup, force = TRUE)
        if (installed && file.exists(manifest_backup)) unlink(manifest_backup, force = TRUE)
        if (file.exists(manifest_tmp)) unlink(manifest_tmp, force = TRUE)
    }, add = TRUE)

    if (!file.rename(candidate, path)) {
        cli::cli_abort("No se pudo instalar la nueva base SQLite.")
    }
    if (!file.rename(manifest_tmp, manifest_path)) {
        cli::cli_abort("No se pudo guardar el manifiesto SQLite local.")
    }
    installed <- TRUE
    invisible(path)
}
