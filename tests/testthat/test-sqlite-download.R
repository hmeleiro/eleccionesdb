test_that("update check compares the remote and local manifests", {
    path <- tempfile(fileext = ".sqlite")
    writeBin(charToRaw("database"), path)
    hash <- eleccionesdb:::edb_sha256(path)
    manifest <- list(
        schema_version = 1L, generated_at = "2026-06-19T00:00:00Z",
        url = "https://example.com/eleccionesdb_sqlite.zip",
        archive_size = 10, archive_sha256 = paste(rep("a", 64), collapse = ""),
        database_filename = "eleccionesdb.sqlite", database_size = file.info(path)$size,
        database_sha256 = hash
    )
    local_mocked_bindings(edb_sqlite_remote_manifest = function() manifest)
    result <- edb_check_sqlite_update(path)
    expect_false(result$update_available)
})

test_that("download installs a validated archive and avoids repeat download", {
    source_db <- create_test_sqlite()
    zip_path <- tempfile(fileext = ".zip")
    old <- setwd(dirname(source_db))
    on.exit(setwd(old), add = TRUE)
    file.copy(source_db, file.path(dirname(source_db), "eleccionesdb.sqlite"), overwrite = TRUE)
    zip::zipr(zip_path, "eleccionesdb.sqlite")

    manifest <- list(
        schema_version = 1L, generated_at = "2026-06-19T00:00:00Z",
        url = "https://example.com/eleccionesdb_sqlite.zip",
        archive_size = unname(file.info(zip_path)$size),
        archive_sha256 = eleccionesdb:::edb_sha256(zip_path),
        database_filename = "eleccionesdb.sqlite",
        database_size = unname(file.info(source_db)$size),
        database_sha256 = eleccionesdb:::edb_sha256(source_db)
    )
    downloads <- 0L
    local_mocked_bindings(
        edb_sqlite_remote_manifest = function() manifest,
        edb_download_file = function(url, path) {
            downloads <<- downloads + 1L
            file.copy(zip_path, path, overwrite = TRUE)
            invisible(path)
        }
    )
    destination <- file.path(tempfile("install_"), "eleccionesdb.sqlite")
    installed <- edb_download_sqlite(destination)
    expect_true(file.exists(installed))
    expect_true(file.exists(paste0(installed, ".json")))
    expect_equal(downloads, 1L)

    edb_download_sqlite(destination)
    expect_equal(downloads, 1L)

    edb_download_sqlite(destination, force = TRUE)
    expect_equal(downloads, 2L)
})

test_that("invalid manifests and checksums are rejected", {
    invalid <- list(schema_version = 2L)
    expect_error(eleccionesdb:::edb_validate_manifest(invalid), "no contiene")

    path <- tempfile()
    writeBin(charToRaw("contenido"), path)
    expect_error(
        eleccionesdb:::edb_assert_sha256(path, paste(rep("0", 64), collapse = ""), "archivo"),
        "no coincide"
    )
})
