test_that("get_territorios returns paginated tibble", {
    local_mocked_bindings(edb_get = function(...) fixture_territorios_pag)
    tbl <- get_territorios(tipo = "ccaa")
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 2)
    expect_true("nombre" %in% names(tbl))
    expect_equal(attr(tbl, "edb_total"), 19L)
})

test_that("get_territorio returns 1-row tibble with all codes", {
    local_mocked_bindings(edb_get = function(...) fixture_territorio_detail)
    tbl <- get_territorio(1)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)
    expect_true("codigo_municipio" %in% names(tbl))
    expect_true("parent_id" %in% names(tbl))
    expect_equal(tbl$codigo_circunscripcion, "99")
    expect_true(is.na(tbl$parent_id))
})

test_that("get_territorio_hijos returns paginated tibble", {
    fixture_hijos <- list(
        total = 8L, skip = 0L, limit = 3L,
        data = list(
            list(
                id = 20L, tipo = "provincia", nombre = "Almeria",
                codigo_completo = "0104999999999", codigo_ccaa = "01",
                codigo_provincia = "04"
            )
        )
    )
    local_mocked_bindings(edb_get = function(...) fixture_hijos)
    tbl <- get_territorio_hijos(1)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)
    expect_equal(tbl$tipo, "provincia")
})
