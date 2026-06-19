# List per-party votes (cross-election)

Returns paginated per-party vote records with flexible filters.

## Usage

``` r
get_votos_partido(
  year = NULL,
  tipo_eleccion = NULL,
  tipo_territorio = NULL,
  codigo_ccaa = NULL,
  codigo_provincia = NULL,
  codigo_municipio = NULL,
  ...,
  eleccion_id = NULL,
  territorio_id = NULL,
  partido_id = NULL,
  limit = 50L,
  skip = 0L,
  all_pages = FALSE,
  denormalize = FALSE,
  use_recode = FALSE,
  clean = denormalize,
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

  Logical. If `TRUE`, fetches all pages. Default `FALSE`.

- denormalize:

  Logical. If `TRUE`, adds descriptive columns next to ID columns:
  `eleccion_descripcion` (after `eleccion_id`), `territorio_nombre`
  (after `territorio_id`), and `partido_nombre` (after `partido_id`).
  Requires additional lookups. Default `FALSE`.

- use_recode:

  Logical. If `TRUE` and `denormalize = TRUE`, the `partido_nombre`
  column uses the recode group name (`agrupacion`) instead of the party
  abbreviation (`siglas`). Falls back to `siglas` when the party has no
  recode. Default `FALSE`.

- clean:

  Logical. If `TRUE`, removes ID and slug columns from the result.
  Defaults to the value of `denormalize`.

- api_key:

  (Opcional) Clave de API para sobrescribir la global solo en esta
  llamada.

## Value

A tibble with columns: `id`, `eleccion_id`, `territorio_id`,
`partido_id`, `votos`, `representantes`. When `denormalize = TRUE`,
additional columns `eleccion_descripcion`, `territorio_nombre`, and
`partido_nombre` are inserted after their corresponding ID columns. When
`clean = TRUE`, ID and slug columns are removed.

## Examples

``` r
if (FALSE) { # \dontrun{
# Votes in general elections of 2019
get_votos_partido(
    year = "2019", tipo_eleccion = "G",
    tipo_territorio = "provincia"
)

# With denormalized names using recode grouping
get_votos_partido(
    year = "2019", tipo_eleccion = "G",
    tipo_territorio = "provincia",
    denormalize = TRUE, use_recode = TRUE, all_pages = TRUE
)
} # }
```
