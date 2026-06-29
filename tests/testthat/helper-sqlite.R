create_test_sqlite <- function(path = tempfile(fileext = ".sqlite"), schema_version = 2L) {
    skip_if_not_installed("DBI")
    skip_if_not_installed("RSQLite")
    con <- DBI::dbConnect(RSQLite::SQLite(), path)
    on.exit(DBI::dbDisconnect(con), add = TRUE)

    ddl <- c(
        paste0("PRAGMA user_version = ", schema_version),
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
            "partido_recode TEXT, agrupacion TEXT, bloque TEXT, color TEXT,",
            "color_pastel TEXT, color_oscuro TEXT)"
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
        ),
        paste(
            "CREATE TABLE elecciones_fuentes (eleccion_id INTEGER PRIMARY KEY,",
            "fuente TEXT, url_fuente TEXT, observaciones TEXT)"
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
        id = c(1L, 20L, 21L, 22L, 23L, 24L),
        tipo = c(
            "ccaa", "provincia", "cera", "circunscripcion", "municipio", "seccion"
        ),
        codigo_ccaa = rep("01", 6),
        codigo_provincia = c("99", "04", "99", "04", "04", "04"),
        codigo_municipio = c("999", "999", "999", "999", "001", "001"),
        codigo_distrito = c("99", "99", "99", "99", "99", "01"),
        codigo_seccion = c("9999", "9999", "9999", "9999", "9999", "0001"),
        codigo_circunscripcion = c("99", "99", "001", "041", "041", "041"),
        nombre = c(
            "Andalucia", "Almeria", "CERA Andalucia",
            "Circunscripcion Almeria", "Abla", "Abla distrito 1 seccion 1"
        ),
        codigo_completo = c(
            "0199999999999", "0104999999999", "0199999999001",
            "0104999999999", "0104001999999", "0104001010001"
        ),
        parent_id = c(NA, 1L, 1L, 20L, 20L, 23L)
    ), append = TRUE)
    DBI::dbWriteTable(con, "partidos_recode", data.frame(
        id = c(73L, 80L), partido_recode = c("PP", "PSOE"),
        agrupacion = c("PP", "PSOE"), bloque = c("derecha", "izquierda"),
        color = c("#0056A5", "#E30613"),
        color_pastel = c("#9cc3e6", "#f4a3a3"),
        color_oscuro = c("#003f7d", "#a80000")
    ), append = TRUE)
    DBI::dbWriteTable(con, "elecciones_fuentes", data.frame(
        eleccion_id = 208L,
        fuente = "Ministerio del Interior",
        url_fuente = "https://example.com",
        observaciones = NA_character_
    ), append = TRUE)
    DBI::dbWriteTable(con, "partidos", data.frame(
        id = c(8180L, 9451L), partido_recode_id = c(73L, 80L),
        siglas = c("PP", "PSOE"),
        denominacion = c("PARTIDO POPULAR", "PARTIDO SOCIALISTA OBRERO ESPANOL")
    ), append = TRUE)
    DBI::dbWriteTable(con, "resumen_territorial", data.frame(
        id = 408788:408793, eleccion_id = rep(208L, 6),
        territorio_id = c(20L, 21L, 1L, 22L, 23L, 24L),
        censo_ine = c(500556L, 5000L, 1000000L, 250000L, 1000L, 800L),
        participacion_1 = c(182762L, 1000L, 400000L, 90000L, 400L, 300L),
        participacion_2 = c(259071L, 2000L, 600000L, 150000L, 600L, 500L),
        participacion_3 = rep(NA_integer_, 6),
        votos_validos = c(328097L, 3000L, 700000L, 180000L, 700L, 600L),
        abstenciones = c(169541L, 2000L, 300000L, 70000L, 300L, 200L),
        votos_blancos = c(2283L, 20L, 5000L, 1000L, 5L, 4L),
        votos_nulos = c(2918L, 30L, 6000L, 1200L, 6L, 5L),
        nrepresentantes = c(6L, 0L, 20L, 5L, 0L, 0L)
    ), append = TRUE)
    DBI::dbWriteTable(con, "votos_territoriales", data.frame(
        id = 5732189:5732195, eleccion_id = rep(208L, 7),
        territorio_id = c(20L, 20L, 21L, 1L, 22L, 23L, 24L),
        partido_id = c(8180L, 9451L, 9451L, 9451L, 9451L, 9451L, 9451L),
        votos = c(73952L, 98924L, 2500L, 400000L, 100000L, 500L, 450L),
        representantes = c(2L, 2L, 0L, 10L, 3L, 0L, 0L)
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
