#' @keywords internal
#' @importFrom rlang %||%
"_PACKAGE"

#' eleccionesdb: R client for EleccionesDB electoral data
#'
#' Provides functions to access Spanish electoral data through the eleccionesdb
#' REST API or an optional local SQLite snapshot. Query functions keep the same
#' interface in both backends and return tidy tibbles ready for analysis.
#'
#' @section Backend de datos:
#' La API es el backend predeterminado. Descarga el snapshot local con
#' [edb_download_sqlite()] y actívalo para la sesión con
#' `edb_set_backend("sqlite")`. Consulta `vignette("backend-sqlite")` para más
#' detalles sobre actualizaciones, rutas personalizadas y fallback.
#'
#' @section Autenticación y configuración:
#' Desde abril de 2026, la mayoría de endpoints requieren autenticación mediante API key.
#' Registra tu clave con [edb_set_api_key()] para que se use automáticamente en todas las funciones protegidas.
#' Puedes sobrescribir la clave global pasando `api_key` como argumento en cada función.
#'
#' La URL base de la API se puede configurar con:
#' - La variable de entorno `ELECCIONESDB_URL` (leída al cargar el paquete)
#' - [edb_set_base_url()] en tiempo de ejecución
#'
#' @section Main functions:
#'
#' **Elections:**
#' - [get_tipos_eleccion()] — catalogue of election types
#' - [get_tipo_eleccion()] — single election type by code
#' - [get_elecciones()] — list elections (paginated, filterable)
#' - [get_eleccion()] — single election detail
#'
#' **Territories:**
#' - [get_territorios()] — list territories (paginated, filterable)
#' - [get_territorio()] — single territory detail
#' - [get_territorio_hijos()] — child territories (hierarchy)
#'
#' **Parties:**
#' - [get_partidos()] — list parties (paginated, filterable)
#' - [get_partido()] — single party detail (with recode)
#' - [get_partidos_recode()] — list recode groups (paginated)
#' - [get_partido_recode()] — single recode group with party list
#'
#' **Results:**
#' - [get_totales_territorio_eleccion()] — territorial totals for an election
#' - [get_resultado_completo()] — full result (totals + votes) for election+territory
#' - [get_totales_territorio()] — territorial totals (cross-election)
#' - [get_votos_partido()] — per-party votes (cross-election)
#' - [get_resultados()] — fully expanded votes (best for analysis)
#'
#' **CERA (overseas vote):**
#' - [get_cera_resumen()] — overseas summaries
#' - [get_cera_votos()] — overseas per-party votes
#'
#' @section Pagination:
#' All list endpoints support `limit`, `skip`, and `all_pages` parameters.
#' Set `all_pages = TRUE` to automatically fetch all records.
#'
#' @details
#' This is a package-level documentation file for eleccionesdb.
#' @name eleccionesdb-package
NULL
