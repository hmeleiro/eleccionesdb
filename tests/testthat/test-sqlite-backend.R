test_that("backend configuration defaults to API and validates SQLite", {
    old <- edb_set_backend("api")
    withr::defer({
        if (identical(old$backend, "sqlite")) {
            edb_set_backend("sqlite", old$path)
        } else {
            edb_set_backend("api")
        }
    })
    expect_identical(edb_get_backend()$backend, "api")
    expect_error(edb_set_backend("sqlite", tempfile()), "No se encuentra")

    path <- create_test_sqlite()
    edb_set_backend("sqlite", path)
    expect_identical(edb_get_backend()$backend, "sqlite")
    expect_equal(edb_get_backend()$path, normalizePath(path, winslash = "/"))
})

test_that("SQLite serves master-data functions with pagination", {
    local_sqlite_backend()

    expect_equal(get_tipos_eleccion()$codigo, c("G", "L"))
    expect_equal(get_tipo_eleccion("G")$descripcion, "Congreso")
    expect_s3_class(get_elecciones(year = "2019")$fecha, "Date")
    expect_equal(get_eleccion(208)$tipo_descripcion, "Congreso")

    territorios <- get_territorios(tipo = "provincia", all_pages = TRUE)
    expect_equal(territorios$nombre, "Almeria")
    expect_equal(attr(territorios, "edb_total"), 1L)
    expect_equal(get_territorio_hijos(1, all_pages = TRUE)$id, c(20L, 21L))

    expect_equal(get_partidos(siglas = "pso")$id, 9451L)
    expect_equal(get_partido(9451)$recode_agrupacion, "PSOE")
    expect_equal(get_partidos_recode(agrupacion = "PSOE")$id, 80L)
    expect_equal(get_partido_recode(80)$partidos$id, 9451L)
})

test_that("SQLite filters and denormalizes result tables", {
    local_sqlite_backend()

    totales <- get_totales_territorio(
        year = "2019", tipo_territorio = "provincia",
        denormalize = TRUE, clean = FALSE
    )
    expect_equal(nrow(totales), 1L)
    expect_equal(totales$eleccion_descripcion, "Elecciones Generales 2019")
    expect_equal(totales$territorio_nombre, "Almeria")

    votos <- get_votos_partido(
        eleccion_id = 208, territorio_id = 20,
        denormalize = TRUE, use_recode = TRUE, all_pages = TRUE
    )
    expect_equal(nrow(votos), 2L)
    expect_setequal(votos$partido_nombre, c("PP", "PSOE"))

    completo <- get_resultado_completo(208, 20)
    expect_equal(nrow(completo$totales_territorio), 1L)
    expect_equal(nrow(completo$votos_partido), 2L)
    expect_true("partido_siglas" %in% names(completo$votos_partido))
})

test_that("SQLite builds clean combined results and CERA results", {
    local_sqlite_backend()

    resultados <- get_resultados(
        year = "2019", tipo_territorio = "provincia", all_pages = TRUE
    )
    expect_equal(nrow(resultados), 2L)
    expect_true(all(c("territorio_nombre", "siglas", "censo_ine") %in% names(resultados)))
    expect_setequal(resultados$siglas, c("PP", "PSOE"))

    expect_equal(nrow(get_cera_resumen(year = "2019")), 1L)
    expect_equal(get_cera_votos(year = "2019")$votos, 2500L)
})

test_that("get_health warns before falling back to the API", {
    local_sqlite_backend()
    local_mocked_bindings(edb_get = function(...) fixture_health)
    expect_warning(health <- get_health(), "se usara la API")
    expect_equal(health$status, "ok")
})
