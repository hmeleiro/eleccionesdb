# Package index

## Consulta principal

Funciones de alto nivel para análisis directo. Punto de entrada
recomendado para la mayoría de casos de uso. Devuelven un tibble listo
para analizar con votos, partido, recode, territorio y totales
territoriales ya combinados en una sola tabla.

- [`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
  : List combined results — main analysis function
- [`get_ccaa()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_ccaa.md)
  : Results by autonomous community
- [`get_provincias()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_provincias.md)
  : Results by province
- [`get_municipios()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_municipios.md)
  : Results by municipality
- [`get_secciones()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_secciones.md)
  : Results by census section

## Elecciones

- [`get_tipos_eleccion()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_tipos_eleccion.md)
  : List all election types
- [`get_tipo_eleccion()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_tipo_eleccion.md)
  : Get a single election type by code
- [`get_elecciones()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_elecciones.md)
  : List elections with optional filters
- [`get_eleccion()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_eleccion.md)
  : Get a single election by ID

## Territorios

- [`get_territorios()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_territorios.md)
  : List territories with optional filters
- [`get_territorio()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_territorio.md)
  : Get a single territory by ID
- [`get_territorio_hijos()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_territorio_hijos.md)
  : List child territories (hierarchical navigation)

## Partidos

- [`get_partidos()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_partidos.md)
  : List political parties with optional filters
- [`get_partido()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_partido.md)
  : Get a single party by ID
- [`get_partidos_recode()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_partidos_recode.md)
  : List party recode/groups with optional filter
- [`get_partido_recode()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_partido_recode.md)
  : Get a single party recode/group by ID

## Resultados (avanzado)

Funciones de acceso a bajo nivel para obtener datos crudos con IDs
normalizados, opciones de desnormalización y control granular de la
paginación.

- [`get_totales_territorio_eleccion()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_totales_territorio_eleccion.md)
  : List territorial totals for an election
- [`get_resultado_completo()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultado_completo.md)
  : Get complete result for an election and territory
- [`get_totales_territorio()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_totales_territorio.md)
  : List territorial totals (cross-election)
- [`get_votos_partido()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_votos_partido.md)
  : List per-party votes (cross-election)

## Voto exterior (CERA)

- [`get_cera_resumen()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_cera_resumen.md)
  : List CERA (overseas vote) summaries
- [`get_cera_votos()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_cera_votos.md)
  : List CERA (overseas) per-party votes

## Utilidades

- [`get_health()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_health.md)
  : Check API health status

## Configuración avanzada

Funciones para apuntar el paquete a una instancia propia de la API. Ver
[`vignette("autodespliegue")`](https://hmeleiro.github.io/eleccionesdb-r/articles/autodespliegue.md)
para más detalles.

- [`edb_set_api_key()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_set_api_key.md)
  : Set the EleccionesDB API key
- [`edb_get_api_key()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_get_api_key.md)
  : Get the current EleccionesDB API key
- [`edb_set_base_url()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_set_base_url.md)
  : Set the EleccionesDB API base URL
- [`edb_get_base_url()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_get_base_url.md)
  : Get the current EleccionesDB API base URL
- [`edb_set_backend()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_set_backend.md)
  : Configure the EleccionesDB data backend
- [`edb_get_backend()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_get_backend.md)
  : Inspect the active EleccionesDB backend
- [`edb_sqlite_path()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_sqlite_path.md)
  : Default path for the EleccionesDB SQLite snapshot
- [`edb_download_sqlite()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_download_sqlite.md)
  : Download or update the EleccionesDB SQLite snapshot
- [`edb_check_sqlite_update()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_check_sqlite_update.md)
  : Check whether a newer SQLite snapshot is available
