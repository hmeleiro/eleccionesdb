# List CERA (overseas) per-party votes

Returns paginated per-party votes for the overseas electorate.

## Usage

``` r
get_cera_votos(
  year = NULL,
  tipo_eleccion = NULL,
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
`partido_id`, `votos`. When `denormalize = TRUE`, additional columns
`eleccion_descripcion`, `territorio_nombre`, and `partido_nombre` are
inserted after their corresponding ID columns. When `clean = TRUE`, ID
and slug columns are removed.

## Examples

``` r
if (FALSE) { # \dontrun{
get_cera_votos(tipo_eleccion = "G", year = "2019")

# With denormalized names using recode grouping
get_cera_votos(
    tipo_eleccion = "G",
    denormalize = TRUE, use_recode = TRUE
)
} # }
```
