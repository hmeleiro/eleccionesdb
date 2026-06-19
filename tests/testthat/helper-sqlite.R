create_test_sqlite <- function(path = tempfile(fileext = ".sqlite")) {
    skip_if_not_installed("DBI")
    skip_if_not_installed("RSQLite")
    con <- DBI::dbConnect(RSQLite::SQLite(), path)
    on.exit(DBI::dbDisconnect(con), add = TRUE)

    ddl <- c(
        "PRAGMA user_version = 1",
        "CREATE TABLE tipos_eleccion (codigo TEXT PRIMARY KEY, descripcion TEXT NOT NULL)",
        paste(
            "CREATE TABLE elecciones (id INTEGER PRIMARY KEY, tipo_eleccion TEXT,",
            "year TEXT, mes TEXT, dia TEXT, fecha TEXT, codigo_ccaa TEXT,",
            "numero_vuelta INTEGER, descripcion TEXT, ambito TEXT, slug TEXT)"
        ),
        paste(
            "CREATE TABLE territorios (id INTEGER PRIMARY KEY, tipo TEXT,",
            "codigo_ccaa TEXT, codigo_provincia TEXT, codigo_municipio TEXT,",
            "codigo_distrito TEXT, codigo_seccion TEXT, codigo_circunscripcion TEXT,",
            "nombre TEXT, codigo_completo TEXT, parent_id INTEGER)"
        ),
        paste(
            "CREATE TABLE partidos_recode (id INTEGER PRIMARY KEY,",
            "partido_recode TEXT, agrupacion TEXT, color TEXT)"
        ),
        paste(
            "CREATE TABLE partidos (id INTEGER PRIMARY KEY, partido_recode_id INTEGER,",
            "siglas TEXT, denominacion TEXT)"
        ),
        paste(
            "CREATE TABLE resumen_territorial (id INTEGER PRIMARY KEY,",
            "eleccion_id INTEGER, territorio_id INTEGER, censo_ine INTEGER,",
            "participacion_1 INTEGER, participacion_2 INTEGER, participacion_3 INTEGER,",
            "votos_validos INTEGER, abstenciones INTEGER, votos_blancos INTEGER,",
            "votos_nulos INTEGER, nrepresentantes INTEGER)"
        ),
        paste(
            "CREATE TABLE votos_territoriales (id INTEGER PRIMARY KEY,",
            "eleccion_id INTEGER, territorio_id INTEGER, partido_id INTEGER,",
            "votos INTEGER, representantes INTEGER)"
        )
    )
    for (sql in ddl) DBI::dbExecute(con, sql)

    DBI::dbWriteTable(con, "tipos_eleccion", data.frame(
        codigo = c("G", "L"), descripcion = c("Congreso", "Locales")
    ), append = TRUE)
    DBI::dbWriteTable(con, "elecciones", data.frame(
        id = 208L, tipo_eleccion = "G", year = "2019", mes = "04", dia = "28",
        fecha = "2019-04-28", codigo_ccaa = "99", numero_vuelta = 1L,
        descripcion = "Elecciones Generales 2019", ambito = "Nacional",
        slug = "elecciones-generales-2019"
    ), append = TRUE)
    DBI::dbWriteTable(con, "territorios", data.frame(
        id = c(1L, 20L, 21L), tipo = c("ccaa", "provincia", "cera"),
        codigo_ccaa = c("01", "01", "01"),
        codigo_provincia = c("99", "04", "99"),
        codigo_municipio = c("999", "999", "999"),
        codigo_distrito = c("99", "99", "99"),
        codigo_seccion = c("9999", "9999", "9999"),
        codigo_circunscripcion = c(NA, NA, "001"),
        nombre = c("Andalucia", "Almeria", "CERA Andalucia"),
        codigo_completo = c("0199999999999", "0104999999999", "0199999999001"),
        parent_id = c(NA, 1L, 1L)
    ), append = TRUE)
    DBI::dbWriteTable(con, "partidos_recode", data.frame(
        id = c(73L, 80L), partido_recode = c("PP", "PSOE"),
        agrupacion = c("PP", "PSOE"), color = c("#0056A5", "#E30613")
    ), append = TRUE)
    DBI::dbWriteTable(con, "partidos", data.frame(
        id = c(8180L, 9451L), partido_recode_id = c(73L, 80L),
        siglas = c("PP", "PSOE"),
        denominacion = c("PARTIDO POPULAR", "PARTIDO SOCIALISTA OBRERO ESPANOL")
    ), append = TRUE)
    DBI::dbWriteTable(con, "resumen_territorial", data.frame(
        id = c(408788L, 408789L), eleccion_id = c(208L, 208L),
        territorio_id = c(20L, 21L), censo_ine = c(500556L, 5000L),
        participacion_1 = c(182762L, 1000L), participacion_2 = c(259071L, 2000L),
        participacion_3 = c(NA, NA), votos_validos = c(328097L, 3000L),
        abstenciones = c(169541L, 2000L), votos_blancos = c(2283L, 20L),
        votos_nulos = c(2918L, 30L), nrepresentantes = c(6L, 0L)
    ), append = TRUE)
    DBI::dbWriteTable(con, "votos_territoriales", data.frame(
        id = c(5732189L, 5732190L, 5732191L), eleccion_id = rep(208L, 3),
        territorio_id = c(20L, 20L, 21L), partido_id = c(8180L, 9451L, 9451L),
        votos = c(73952L, 98924L, 2500L), representantes = c(2L, 2L, 0L)
    ), append = TRUE)
    path
}

local_sqlite_backend <- function(path = create_test_sqlite(), env = parent.frame()) {
    old <- edb_get_backend()
    edb_set_backend("sqlite", path)
    withr::defer({
        if (identical(old$backend, "sqlite")) {
            edb_set_backend("sqlite", old$path)
        } else {
            edb_set_backend("api")
        }
    }, envir = env)
    path
}
