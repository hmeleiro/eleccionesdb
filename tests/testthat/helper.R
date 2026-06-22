# ---------- JSON Fixtures (from api-examples.json) ----------

fixture_health <- list(
    status = "ok",
    environment = "development",
    database = "ok"
)

fixture_tipos_eleccion <- list(
    list(codigo = "A", descripcion = "Autonomicas"),
    list(codigo = "E", descripcion = "Europeas"),
    list(codigo = "G", descripcion = "Congreso"),
    list(codigo = "L", descripcion = "Locales"),
    list(codigo = "S", descripcion = "Senado")
)

fixture_tipo_eleccion_g <- list(codigo = "G", descripcion = "Congreso")

fixture_elecciones_pag <- list(
    total = 254L,
    skip = 0L,
    limit = 3L,
    data = list(
        list(
            id = 1L, tipo_eleccion = "G", year = "1977", mes = "06", dia = "15",
            fecha = "1977-06-15", descripcion = "Elecciones Generales 1977",
            ambito = "Nacional", slug = "elecciones-generales-1977"
        ),
        list(
            id = 2L, tipo_eleccion = "G", year = "1979", mes = "03", dia = "01",
            fecha = "1979-03-01", descripcion = "Elecciones Generales 1979",
            ambito = "Nacional", slug = "elecciones-generales-1979"
        ),
        list(
            id = 3L, tipo_eleccion = "A", year = "1979", mes = "04", dia = "03",
            fecha = "1979-04-03", descripcion = "Elecciones Autonomicas Navarra 1979",
            ambito = "Autonomico", slug = "elecciones-autonomicas-1979"
        )
    )
)

fixture_eleccion_detail <- list(
    id = 208L, tipo_eleccion = "G", year = "2019", mes = "04", dia = "28",
    fecha = "2019-04-28", codigo_ccaa = "99", numero_vuelta = 1L,
    descripcion = "Elecciones Generales 2019", ambito = "Nacional",
    slug = "elecciones-generales-2019",
    tipo = list(codigo = "G", descripcion = "Congreso")
)

fixture_empty_pag <- list(total = 0L, skip = 0L, limit = 50L, data = list())

fixture_territorios_pag <- list(
    total = 19L, skip = 0L, limit = 5L,
    data = list(
        list(
            id = 1L, tipo = "ccaa", nombre = "Andalucia",
            codigo_completo = "0199999999999", codigo_ccaa = "01",
            codigo_provincia = "99"
        ),
        list(
            id = 2L, tipo = "ccaa", nombre = "Aragon",
            codigo_completo = "0299999999999", codigo_ccaa = "02",
            codigo_provincia = "99"
        )
    )
)

fixture_territorio_detail <- list(
    id = 1L, tipo = "ccaa", codigo_ccaa = "01", codigo_provincia = "99",
    codigo_municipio = "999", codigo_distrito = "99", codigo_seccion = "9999",
    codigo_circunscripcion = NULL, nombre = "Andalucia",
    codigo_completo = "0199999999999", parent_id = NULL
)

fixture_partidos_pag <- list(
    total = 345L, skip = 0L, limit = 3L,
    data = list(
        list(
            id = 5082L, siglas = "IU-PSOE", denominacion = "IU-PSOE",
            partido_recode_id = 47L
        ),
        list(
            id = 8432L, siglas = "ADEIA,PSM,PSOE,IV",
            denominacion = "AGRUPACIO DEIA,PSM,PSOE,IVERDS",
            partido_recode_id = 80L
        )
    )
)

fixture_partido_with_recode <- list(
    id = 5082L, siglas = "IU-PSOE", denominacion = "IU-PSOE",
    partido_recode_id = 47L,
    recode = list(
        id = 47L, partido_recode = "IU",
        agrupacion = "PCE/IU", color = "#E51635"
    )
)

fixture_partido_without_recode <- list(
    id = 11911L, siglas = "PACMA",
    denominacion = "PARTIDO ANIMALISTA CONTRA EL MALTRATO ANIMAL",
    partido_recode_id = NULL, recode = NULL
)

fixture_partido_recode_detail <- list(
    id = 47L, partido_recode = "IU", agrupacion = "PCE/IU", color = "#E51635",
    partidos = list(
        list(
            id = 3974L, siglas = "(GANAR) (GA)",
            denominacion = "(GANAR) (GA)", partido_recode_id = 47L
        ),
        list(
            id = 4991L, siglas = "IU", denominacion = "IU",
            partido_recode_id = 47L
        )
    )
)

fixture_resumen_pag <- list(
    total = 8L, skip = 0L, limit = 2L,
    data = list(
        list(
            id = 408788L, eleccion_id = 208L, territorio_id = 20L,
            censo_ine = 500556L, participacion_1 = 182762L,
            participacion_2 = 259071L, participacion_3 = NULL,
            votos_validos = 328097L, abstenciones = 169541L,
            votos_blancos = 2283L, votos_nulos = 2918L, nrepresentantes = 6L
        ),
        list(
            id = 408789L, eleccion_id = 208L, territorio_id = 21L,
            censo_ine = 1000032L, participacion_1 = 361498L,
            participacion_2 = 535223L, participacion_3 = NULL,
            votos_validos = 667562L, abstenciones = 324120L,
            votos_blancos = 8206L, votos_nulos = 8350L, nrepresentantes = 9L
        )
    )
)

fixture_resultado_completo <- list(
    totales_territorio = list(
        id = 408788L, eleccion_id = 208L, territorio_id = 20L,
        censo_ine = 500556L, participacion_1 = 182762L,
        participacion_2 = 259071L, participacion_3 = NULL,
        votos_validos = 328097L, abstenciones = 169541L,
        votos_blancos = 2283L, votos_nulos = 2918L, nrepresentantes = 6L
    ),
    votos_partido = list(
        list(
            id = 5732190L, eleccion_id = 208L, territorio_id = 20L,
            partido_id = 9451L, votos = 98924L, representantes = 2L,
            partido = list(
                id = 9451L, siglas = "PSOE",
                denominacion = "PARTIDO SOCIALISTA OBRERO ESPANOL",
                partido_recode_id = 80L
            )
        ),
        list(
            id = 5732189L, eleccion_id = 208L, territorio_id = 20L,
            partido_id = 8180L, votos = 73952L, representantes = 2L,
            partido = list(
                id = 8180L, siglas = "PP",
                denominacion = "PARTIDO POPULAR",
                partido_recode_id = 73L
            )
        )
    )
)

fixture_votos_pag <- list(
    total = 10L, skip = 0L, limit = 3L,
    data = list(
        list(
            id = 5732188L, eleccion_id = 208L, territorio_id = 20L,
            partido_id = 1831L, votos = 56268L, representantes = 1L
        ),
        list(
            id = 5732189L, eleccion_id = 208L, territorio_id = 20L,
            partido_id = 8180L, votos = 73952L, representantes = 2L
        )
    )
)

fixture_combinados_pag <- list(
    total = 1L, skip = 0L, limit = 1L,
    data = list(
        list(
            id = 5732188L, eleccion_id = 208L, territorio_id = 20L,
            partido_id = 1831L, votos = 56268L, representantes = 1L,
            partido = list(
                id = 1831L, siglas = "CS",
                denominacion = "CIUDADANOS-PARTIDO DE LA CIUDADANIA",
                partido_recode_id = 29L,
                recode = list(
                    id = 29L, partido_recode = "Cs",
                    agrupacion = "Cs", color = "#ED6C00"
                )
            ),
            territorio = list(
                id = 20L, tipo = "provincia", nombre = "Almeria",
                codigo_completo = "0104999999999",
                codigo_ccaa = "01", codigo_provincia = "04",
                codigo_circunscripcion = "04"
            ),
            eleccion = list(
                id = 208L, tipo_eleccion = "G", year = "2019",
                mes = "04", dia = "28", fecha = "2019-04-28",
                descripcion = "Elecciones Generales 2019",
                ambito = "Nacional", slug = "elecciones-generales-2019"
            )
        )
    )
)

# Helper: mock edb_get to return a fixture
local_mock_edb_get <- function(fixture, env = parent.frame()) {
    withr::local_options(list(.eleccionesdb_mock = fixture), .local_envir = env)
}
