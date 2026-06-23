# eleccionesdb: R Client for EleccionesDB Electoral Data

Provides functions to access Spanish electoral data through the
EleccionesDB REST API or an optional local SQLite snapshot. Returns tidy
tibbles ready for analysis, supports automatic pagination, and handles
nested JSON structures with sensible flattening. Covers elections,
territories, parties, results, and CERA (overseas vote) endpoints.

Provides functions to access Spanish electoral data through the
eleccionesdb REST API or an optional local SQLite snapshot. Query
functions keep the same interface in both backends and return tidy
tibbles ready for analysis.

## Details

This is a package-level documentation file for eleccionesdb.

## Backend de datos

La API es el backend predeterminado. Descarga el snapshot local con
[`edb_download_sqlite()`](https://eleccionesdb-r.spainelectoralproject.com/reference/edb_download_sqlite.md)
y actívalo para la sesión con `edb_set_backend("sqlite")`. Consulta
[`vignette("backend-sqlite")`](https://eleccionesdb-r.spainelectoralproject.com/articles/backend-sqlite.md)
para más detalles sobre actualizaciones, rutas personalizadas y
fallback.

## Autenticación y configuración

Desde abril de 2026, la mayoría de endpoints requieren autenticación
mediante API key. Registra tu clave con
[`edb_set_api_key()`](https://eleccionesdb-r.spainelectoralproject.com/reference/edb_set_api_key.md)
para que se use automáticamente en todas las funciones protegidas.
Puedes sobrescribir la clave global pasando `api_key` como argumento en
cada función.

La URL base de la API se puede configurar con:

- La variable de entorno `ELECCIONESDB_URL` (leída al cargar el paquete)

- [`edb_set_base_url()`](https://eleccionesdb-r.spainelectoralproject.com/reference/edb_set_base_url.md)
  en tiempo de ejecución

## Main functions

**Elections:**

- [`get_tipos_eleccion()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_tipos_eleccion.md)
  — catalogue of election types

- [`get_tipo_eleccion()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_tipo_eleccion.md)
  — single election type by code

- [`get_elecciones()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_elecciones.md)
  — list elections (paginated, filterable)

- [`get_eleccion()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_eleccion.md)
  — single election detail

**Territories:**

- [`get_territorios()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_territorios.md)
  — list territories (paginated, filterable)

- [`get_territorio()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_territorio.md)
  — single territory detail

- [`get_territorio_hijos()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_territorio_hijos.md)
  — child territories (hierarchy)

**Parties:**

- [`get_partidos()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_partidos.md)
  — list parties (paginated, filterable)

- [`get_partido()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_partido.md)
  — single party detail (with recode)

- [`get_partidos_recode()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_partidos_recode.md)
  — list recode groups (paginated)

- [`get_partido_recode()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_partido_recode.md)
  — single recode group with party list

**Results:**

- [`get_totales_territorio_eleccion()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_totales_territorio_eleccion.md)
  — territorial totals for an election

- [`get_resultado_completo()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_resultado_completo.md)
  — full result (totals + votes) for election+territory

- [`get_totales_territorio()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_totales_territorio.md)
  — territorial totals (cross-election)

- [`get_votos_partido()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_votos_partido.md)
  — per-party votes (cross-election)

- [`get_resultados()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_resultados.md)
  — fully expanded votes (best for analysis)

- [`get_circunscripciones()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_circunscripciones.md)
  — constituency-level expanded results

**CERA (overseas vote):**

- [`get_cera_resumen()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_cera_resumen.md)
  — overseas summaries

- [`get_cera_votos()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_cera_votos.md)
  — overseas per-party votes

## Pagination

All list endpoints support `limit`, `skip`, and `all_pages` parameters.
Set `all_pages = TRUE` to automatically fetch all records.

## See also

Useful links:

- <https://eleccionesdb-r.spainelectoralproject.com/>

- Report bugs at <https://github.com/hmeleiro/eleccionesdb/issues>

## Author

**Maintainer**: Héctor Meleiro <hmeleiro@gmail.com>
