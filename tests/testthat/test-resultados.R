test_that("get_totales_territorio_eleccion returns paginated tibble", {
    local_mocked_bindings(edb_get = function(path, ...) {
        params <- list(...)
        expect_equal(params$codigo_circunscripcion, "99")
        fixture_resumen_pag
    })
    tbl <- get_totales_territorio_eleccion(
        208, tipo_territorio = "provincia", codigo_circunscripcion = "99"
    )
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 2)
    expect_true("censo_ine" %in% names(tbl))
    expect_true("nrepresentantes" %in% names(tbl))
    expect_true(is.na(tbl$participacion_3[1]))
})

test_that("get_resultado_completo returns list with totales_territorio and votos_partido", {
    local_mocked_bindings(edb_get = function(...) fixture_resultado_completo)
    result <- get_resultado_completo(208, 20)
    expect_type(result, "list")
    expect_named(result, c("totales_territorio", "votos_partido"))

    # totales_territorio
    expect_s3_class(result$totales_territorio, "tbl_df")
    expect_equal(nrow(result$totales_territorio), 1)
    expect_equal(result$totales_territorio$censo_ine, 500556L)

    # votos_partido with flattened partido
    expect_s3_class(result$votos_partido, "tbl_df")
    expect_equal(nrow(result$votos_partido), 2)
    expect_true("partido_siglas" %in% names(result$votos_partido))
    expect_false("partido" %in% names(result$votos_partido))
})

test_that("get_totales_territorio returns paginated tibble", {
    local_mocked_bindings(edb_post = function(path, body, ...) {
        expect_equal(body$codigo_circunscripcion, list("99", "331"))
        fixture_resumen_pag
    })
    tbl <- get_totales_territorio(
        eleccion_id = 208, tipo_territorio = "provincia",
        codigo_circunscripcion = c("99", "331")
    )
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 2)
})

test_that("get_votos_partido returns paginated tibble", {
    local_mocked_bindings(edb_post = function(path, body, ...) {
        expect_equal(body$codigo_circunscripcion, list("041"))
        fixture_votos_pag
    })
    tbl <- get_votos_partido(
        eleccion_id = 208, territorio_id = 20,
        codigo_circunscripcion = "041"
    )
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 2)
    expect_true("votos" %in% names(tbl))
    expect_true("representantes" %in% names(tbl))
})

test_that("get_resultados returns clean tibble by default", {
    local_mocked_bindings(edb_post = function(path, body, ...) {
        if (grepl("combinados", path)) fixture_combinados_pag
        else fixture_resumen_pag
    })
    tbl <- get_resultados(eleccion_id = 208)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)

    # Verify clean renamed columns
    expect_true("siglas" %in% names(tbl))
    expect_true("partido_recode" %in% names(tbl))
    expect_true("territorio_nombre" %in% names(tbl))
    expect_equal(tbl$codigo_circunscripcion, "99")
    expect_true("year" %in% names(tbl))
    expect_true("votos" %in% names(tbl))
    expect_true("representantes" %in% names(tbl))

    # Verify enriched summary columns
    expect_true("censo_ine" %in% names(tbl))
    expect_true("votos_validos" %in% names(tbl))
    expect_true("abstenciones" %in% names(tbl))
    expect_true("votos_blancos" %in% names(tbl))
    expect_true("votos_nulos" %in% names(tbl))
    expect_true("nrepresentantes" %in% names(tbl))

    # No raw nested or prefixed columns
    expect_false("partido" %in% names(tbl))
    expect_false("territorio" %in% names(tbl))
    expect_false("eleccion" %in% names(tbl))
    expect_false("id" %in% names(tbl))
    expect_false("partido_siglas" %in% names(tbl))
})

test_that("get_resultados with clean = FALSE returns full flattened tibble with summary cols", {
    local_mocked_bindings(edb_post = function(path, body, ...) {
        if (grepl("combinados", path)) fixture_combinados_pag
        else fixture_resumen_pag
    })
    tbl <- get_resultados(eleccion_id = 208, clean = FALSE)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)

    # Verify full flattened columns
    expect_true("partido_siglas" %in% names(tbl))
    expect_true("recode_agrupacion" %in% names(tbl))
    expect_true("territorio_nombre" %in% names(tbl))
    expect_equal(tbl$territorio_codigo_circunscripcion, "99")
    expect_true("eleccion_year" %in% names(tbl))

    # Verify enriched summary columns also present
    expect_true("censo_ine" %in% names(tbl))
    expect_true("votos_validos" %in% names(tbl))
    expect_true("nrepresentantes" %in% names(tbl))

    # No raw nested columns
    expect_false("partido" %in% names(tbl))
    expect_false("territorio" %in% names(tbl))
    expect_false("eleccion" %in% names(tbl))
})

test_that("get_resultados gracefully handles failed resumen fetch", {
    local_mocked_bindings(edb_post = function(path, body, ...) {
        if (grepl("combinados", path)) fixture_combinados_pag
        else stop("simulated network error")
    })
    tbl <- get_resultados(eleccion_id = 208)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)
    # Summary columns are NA when resumen fetch fails
    expect_true("censo_ine" %in% names(tbl))
    expect_true(is.na(tbl$censo_ine[1]))
})

test_that("territorial wrappers return and filter by codigo_circunscripcion", {
    cases <- list(
        list(fn = get_ccaa, tipo = "ccaa", codigo = "99"),
        list(fn = get_provincias, tipo = "provincia", codigo = "99"),
        list(fn = get_circunscripciones, tipo = "circunscripcion", codigo = "041"),
        list(fn = get_municipios, tipo = "municipio", codigo = "041"),
        list(fn = get_secciones, tipo = "seccion", codigo = "041")
    )

    for (case in cases) {
        combined <- fixture_combinados_territorio(case$tipo, case$codigo)
        local_mocked_bindings(edb_post = function(path, body, ...) {
            if (grepl("combinados", path)) {
                expect_equal(body$tipo_territorio, list(case$tipo))
                expect_equal(body$codigo_circunscripcion, list(case$codigo))
                combined
            } else {
                fixture_resumen_pag
            }
        })
        tbl <- case$fn(
            eleccion_id = 208,
            codigo_circunscripcion = case$codigo,
            all_pages = FALSE
        )
        expect_s3_class(tbl, "tbl_df")
        expect_equal(tbl$codigo_circunscripcion, case$codigo)
    }
})


test_that("get_health returns 1-row tibble", {
    local_mocked_bindings(edb_get = function(...) fixture_health)
    tbl <- get_health()
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)
    expect_equal(tbl$status, "ok")
})
