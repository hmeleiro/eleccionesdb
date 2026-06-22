# eleccionesdb

[![R-CMD-check](https://github.com/hmeleiro/eleccionesdb-r/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hmeleiro/eleccionesdb-r/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

> R client for the [eleccionesdb
> API](https://eleccionesdb-api.spainelectoralproject.com/) — Spanish
> electoral data as tidy tibbles.

## Installation

``` r

# Install with remotes
remotes::install_github("hmeleiro/eleccionesdb-r")
```

## Quick start

``` r

library(eleccionesdb)
library(dplyr)

get_health() # Check API is running
#> # A tibble: 1 × 3
#>   status environment database
#>   <chr>  <chr>       <chr>
#> 1 ok     development ok

# List election types
get_tipos_eleccion()
#> # A tibble: 5 × 2
#>   codigo descripcion
#>   <chr>  <chr>
#> 1 A      Autonomicas
#> 2 E      Europeas
#> 3 G      Congreso
#> 4 L      Locales
#> 5 S      Senado

# General elections in 2019
get_elecciones(tipo_eleccion = "G", year = "2019")
#> # A tibble: 2 × 9
#>      id tipo_eleccion year  mes   dia   fecha      descripcion           ambito   slug
#>   <int> <chr>         <chr> <chr> <chr> <date>     <chr>                 <chr>    <chr>
#> 1   208 G             2019  04    28    2019-04-28 Elecciones Generales… Nacional elecciones…
#> 2   226 G             2019  11    10    2019-11-10 Elecciones Generales… Nacional elecciones…

# Full detail for one election
get_eleccion(208)

# Provincial results for April 2019 general election — clean output
get_resultados(
  tipo_eleccion = "G", year = "2019",
  tipo_territorio = "provincia",
  codigo_ccaa = "01"  # Andalucía
)
```

## Pagination

All list endpoints support pagination:

``` r

# Default: first 50 records
get_elecciones()

# Custom page size
get_elecciones(limit = 100, skip = 50)

# Fetch ALL records automatically (loops through all pages)
get_elecciones(all_pages = TRUE)
```

The tibble returned carries an `"edb_total"` attribute with the total
count:

``` r

tbl <- get_elecciones(tipo_eleccion = "G")
attr(tbl, "edb_total")
#> [1] 16
```

## Backend SQLite

Para consultas grandes o trabajo sin conexión puede descargarse el
snapshot SQLite oficial y usar las mismas funciones del paquete:

``` r

# Requiere los paquetes opcionales DBI, RSQLite, digest y jsonlite
edb_download_sqlite()
edb_set_backend("sqlite")

get_resultados(
  tipo_eleccion = "G", year = "2019",
  tipo_territorio = "municipio"
)

edb_check_sqlite_update()
edb_set_backend("api")
```

La selección dura únicamente durante la sesión y las actualizaciones se
comprueban de forma explícita. Consulta
[`vignette("backend-sqlite")`](https://hmeleiro.github.io/eleccionesdb-r/articles/backend-sqlite.md)
para rutas personalizadas, validación y política de fallback.

## Function reference

### Elections

| Function | Description |
|----|----|
| [`get_tipos_eleccion()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_tipos_eleccion.md) | Catalogue of election types |
| `get_tipo_eleccion(codigo)` | Single election type by code |
| `get_elecciones(...)` | List elections (filterable, paginated) |
| `get_eleccion(id)` | Election detail (with tipo flattened) |

### Territories

| Function                   | Description                              |
|----------------------------|------------------------------------------|
| `get_territorios(...)`     | List territories (filterable, paginated) |
| `get_territorio(id)`       | Territory detail (all codes)             |
| `get_territorio_hijos(id)` | Children of a territory                  |

### Parties

| Function                   | Description                          |
|----------------------------|--------------------------------------|
| `get_partidos(...)`        | List parties (filterable, paginated) |
| `get_partido(id)`          | Party detail (with recode flattened) |
| `get_partidos_recode(...)` | List recode groups (paginated)       |
| `get_partido_recode(id)`   | Recode detail + associated parties   |

### Results

| Function | Description |
|----|----|
| `get_totales_territorio_eleccion(id, ...)` | Territorial totals for one election |
| `get_resultado_completo(elec_id, terr_id)` | Totals + per-party votes |
| `get_totales_territorio(...)` | Territorial totals (cross-election) |
| `get_votos_partido(...)` | Per-party votes (cross-election) |
| `get_resultados(...)` | Fully expanded results (best for analysis) |

### CERA (overseas vote)

| Function                | Description          |
|-------------------------|----------------------|
| `get_cera_resumen(...)` | CERA summaries       |
| `get_cera_votos(...)`   | CERA per-party votes |

## Configuración

#### Cómo obtener tu API key

1.  Regístrate en el [portal de
    desarrolladores](https://eleccionesdb-api.spainelectoralproject.com/developers/)
    de eleccionesdb y verifica tu email.
2.  Recibirás una clave personal que deberás usar en todas las
    peticiones protegidas.

#### Cómo registrar la clave en R

``` r

# Guardar la clave solo para la sesión actual:
edb_set_api_key("TU_API_KEY")

# Guardar la clave de forma persistente (en ~/.Renviron):
edb_set_api_key("TU_API_KEY", persist = TRUE)
# Reinicia R para que esté disponible globalmente.
```

Puedes consultar la clave actual con:

``` r

edb_get_api_key()
```

#### Uso automático y sobrescritura

Todas las funciones que acceden a endpoints protegidos usan la clave
registrada automáticamente. Si lo deseas, puedes pasar una clave
distinta solo para una llamada:

``` r

get_partidos(siglas = "psoe", api_key = "OTRA_CLAVE")
```

#### Funciones de configuración

| Function | Description |
|----|----|
| `edb_set_base_url(url)` | Set API base URL |
| [`edb_get_base_url()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_get_base_url.md) | Get current API base URL |
| `edb_set_api_key(key, persist=FALSE)` | Set API key (session/persistente) |
| [`edb_get_api_key()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_get_api_key.md) | Get current API key |
| [`edb_get_base_url()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_get_base_url.md) | Get current API base URL |
| [`edb_set_backend()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_set_backend.md) | Seleccionar API o SQLite para la sesión |
| [`edb_get_backend()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_get_backend.md) | Consultar el backend activo |
| [`edb_download_sqlite()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_download_sqlite.md) | Descargar o actualizar el snapshot local |
| [`edb_check_sqlite_update()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_check_sqlite_update.md) | Comprobar si hay una versión nueva |
| [`edb_sqlite_path()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_sqlite_path.md) | Ruta local predeterminada |

## Nested data handling

The package flattens nested JSON objects into prefixed columns for easy
analysis:

- **[`get_eleccion()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_eleccion.md)**:
  `tipo` → `tipo_codigo`, `tipo_descripcion`
- **[`get_partido()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_partido.md)**:
  `recode` → `recode_id`, `recode_partido_recode`, `recode_agrupacion`,
  `recode_color`
- **[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)**:
  Flattens and renames `partido.*`, `recode.*`, `territorio.*`,
  `eleccion.*` (`clean = TRUE` by default)

When an endpoint returns heterogeneous structures (a summary + a list of
votes), the function returns a **named list** instead of trying to force
it into one tibble:

``` r

result <- get_resultado_completo(208, 20)
result$totales_territorio  # 1-row tibble with census/participation data
result$votos_partido       # tibble of per-party votes (partido flattened)

recode <- get_partido_recode(47)
recode$recode    # 1-row tibble with group info
recode$partidos  # tibble of associated parties (can be thousands)
```

## Error handling

``` r

# 404 — resource not found
get_eleccion(99999)
#> Error: API error (404): Elección no encontrada

# 422 — validation error
get_elecciones(limit = -5)
#> Error: Error de validacion (422):
#> [query > limit] Input should be greater than or equal to 1

# Network failure
edb_set_base_url("http://nonexistent:9999")
get_health()
#> Error: No se pudo conectar con la API de EleccionesDB.
#> ℹ URL base: http://nonexistent:9999
#> ℹ Verifica que el servidor esta en ejecucion.
```

## License

MIT
