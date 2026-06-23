# List territorial totals for an election

Returns paginated territorial totals (census, participation, blank/null
votes, etc.) for a specific election, with optional territorial filters.

## Usage

``` r
get_totales_territorio_eleccion(
  eleccion_id,
  tipo_territorio = NULL,
  codigo_ccaa = NULL,
  codigo_provincia = NULL,
  codigo_municipio = NULL,
  codigo_circunscripcion = NULL,
  ...,
  territorio_id = NULL,
  limit = 50L,
  skip = 0L,
  all_pages = FALSE,
  denormalize = FALSE,
  clean = denormalize,
  api_key = NULL
)
```

## Arguments

- eleccion_id:

  Integer. The election ID (required).

- tipo_territorio:

  Character vector. Filter by territory type. Valid values: `"ccaa"`,
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

- territorio_id:

  Integer vector. Filter by territory ID(s). Optional.

- limit:

  Integer. Maximum records per page (1-500, default 50).

- skip:

  Integer. Records to skip (default 0).

- all_pages:

  Logical. If `TRUE`, fetches all pages. Default `FALSE`.

- denormalize:

  Logical. If `TRUE`, adds descriptive columns next to ID columns:
  `eleccion_descripcion` (after `eleccion_id`) and `territorio_nombre`
  (after `territorio_id`). Requires additional API calls. Default
  `FALSE`.

- clean:

  Logical. If `TRUE`, removes ID and slug columns from the result.
  Defaults to the value of `denormalize`.

- api_key:

  (Opcional) Clave de API para sobrescribir la global solo en esta
  llamada.

## Value

A tibble with columns: `id`, `eleccion_id`, `territorio_id`,
`censo_ine`, `participacion_1`, `participacion_2`, `participacion_3`,
`votos_validos`, `abstenciones`, `votos_blancos`, `votos_nulos`,
`nrepresentantes`. When `denormalize = TRUE`, additional columns
`eleccion_descripcion` and `territorio_nombre` are inserted after their
corresponding ID columns. When `clean = TRUE`, ID and slug columns are
removed.

## Examples

``` r
if (FALSE) { # \dontrun{
# Totals for a general election, by province
get_totales_territorio_eleccion(208, tipo_territorio = "provincia")

# All totals for an election
get_totales_territorio_eleccion(208, all_pages = TRUE)

# With denormalized names (clean by default)
get_totales_territorio_eleccion(208,
    tipo_territorio = "provincia",
    denormalize = TRUE
)
} # }
```
