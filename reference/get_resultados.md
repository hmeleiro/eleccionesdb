# List combined results — main analysis function

`get_resultados()` is the primary function of the package for analytical
use. It returns a wide, ready-to-analyse tibble that combines per-party
votes with territorial summary data (census, turnout, blank/null votes)
and election metadata, all joined internally so no manual merging is
needed.

## Usage

``` r
get_resultados(
  year = NULL,
  tipo_eleccion = NULL,
  tipo_territorio = NULL,
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

- tipo_territorio:

  Character vector. Filter by territory type(s). Valid values: `"ccaa"`,
  `"provincia"`, `"municipio"`, `"distrito"`, `"seccion"`,
  `"circunscripcion"`, `"cera"`. Optional.

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

A tibble. When `clean = TRUE`: `year`, `mes`, `tipo_eleccion`,
`tipo_territorio`, `territorio_nombre`, `codigo_ccaa`,
`codigo_provincia`, `codigo_circunscripcion`, `codigo_municipio`,
`codigo_distrito`, `codigo_seccion`, `censo_ine`, `votos_validos`,
`abstenciones`, `votos_blancos`, `votos_nulos`, `participacion_1`,
`participacion_2`, `participacion_3`, `siglas`, `denominacion`,
`partido_recode`, `partido_agrupacion`, `votos`, `representantes`,
`nrepresentantes`.

When `clean = FALSE`: all flattened columns with prefixes `partido_*`,
`recode_*`, `territorio_*`, `eleccion_*`, plus the flat summary columns
(`censo_ine`, `votos_validos`, `abstenciones`, `votos_blancos`,
`votos_nulos`, `participacion_1`, `participacion_2`, `participacion_3`,
`nrepresentantes`).

## Details

With the API backend, two calls are made internally: one for expanded
votes and another for territorial totals. With SQLite, the same result
is produced by a local relational query. Both are joined by
`(eleccion_id, territorio_id)` before being returned.

When `clean = TRUE` (the default), prefixed columns are renamed to
short, user-friendly names and only the most useful columns are
returned. Set `clean = FALSE` to get all flattened columns with their
original prefixes (`partido_*`, `recode_*`, `territorio_*`,
`eleccion_*`) plus the flat summary columns.

## Examples

``` r
if (FALSE) { # \dontrun{
# Results by province for Andalucia in the 2019 general election
get_resultados(
    tipo_eleccion = "G", year = "2019",
    tipo_territorio = "provincia",
    codigo_ccaa = "01",
    all_pages = TRUE
)

# Provincial results for all general elections (all pages)
get_resultados(tipo_eleccion = "G", tipo_territorio = "provincia",
               all_pages = TRUE)

# Filter afterwards with dplyr
library(dplyr)
get_resultados(tipo_eleccion = "G", year = "2019",
               tipo_territorio = "provincia", all_pages = TRUE) |>
    filter(siglas == "PSOE") |>
    select(territorio_nombre, votos, representantes,
           censo_ine, votos_validos)

# Full flattened output (no renaming)
get_resultados(tipo_eleccion = "G", year = "2019",
               tipo_territorio = "provincia",
               clean = FALSE)
} # }
```
