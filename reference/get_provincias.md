# Results by province

A convenience wrapper around
[`get_resultados()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_resultados.md)
that pre-sets `tipo_territorio = "provincia"`. See
[`get_resultados()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_resultados.md)
for full details on the returned tibble.

## Usage

``` r
get_provincias(
  year = NULL,
  tipo_eleccion = NULL,
  codigo_ccaa = NULL,
  codigo_provincia = NULL,
  codigo_municipio = NULL,
  codigo_circunscripcion = NULL,
  ...,
  eleccion_id = NULL,
  territorio_id = NULL,
  partido_id = NULL,
  limit = 50L,
  skip = 0L,
  all_pages = TRUE,
  clean = TRUE,
  api_key = NULL
)
```

## Arguments

- year:

  Character vector. Filter by year(s). Optional.

- tipo_eleccion:

  Character vector. Filter by election type code(s). Valid values: `"A"`
  (Autonomicas), `"E"` (Europeas), `"G"` (Congreso), `"L"` (Locales),
  `"S"` (Senado). Optional.

- codigo_ccaa:

  Character vector. Filter by autonomous community INE code(s) (e.g.
  `"01"`, `"13"`). Optional.

- codigo_provincia:

  Character vector. Filter by province INE code(s) (e.g. `"28"`,
  `"08"`). Optional.

- codigo_municipio:

  Character vector. Filter by municipality INE code(s). Optional.

- codigo_circunscripcion:

  Character vector. Filter by constituency code(s), including `"99"` for
  CCAA and provinces. Optional.

- ...:

  Arguments after `...` must be named.

- eleccion_id:

  Integer vector. Filter by election ID(s). Optional.

- territorio_id:

  Integer vector. Filter by territory ID(s). Optional.

- partido_id:

  Integer vector. Filter by party ID(s). Optional.

- limit:

  Integer. Maximum records per page (1-500, default 50).

- skip:

  Integer. Records to skip (default 0).

- all_pages:

  Logical. If `TRUE`, fetches all pages automatically. Default `TRUE`.

- clean:

  Logical. If `TRUE` (default), renames prefixed columns to short names
  and selects only user-friendly columns. If `FALSE`, returns all
  flattened columns.

- api_key:

  Character. Optional API key to override the global setting for this
  call only.

## Value

A tibble as returned by
[`get_resultados()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_resultados.md)
filtered to `tipo_territorio = "provincia"`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Provincial results for general elections in Andalucia
get_provincias(tipo_eleccion = "G", year = "2019",
              codigo_ccaa = "01", all_pages = TRUE)

# Compare PSOE votes across all provinces in 2019
library(dplyr)
get_provincias(tipo_eleccion = "G", year = "2019", all_pages = TRUE) |>
    filter(siglas == "PSOE") |>
    arrange(desc(votos))
} # }
```
