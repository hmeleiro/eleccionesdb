# Get complete result for an election and territory

Returns the territorial summary and per-party vote breakdown for a
specific election-territory combination. This is a composite endpoint
that returns a named list.

## Usage

``` r
get_resultado_completo(
  eleccion_id,
  territorio_id,
  ...,
  denormalize = FALSE,
  use_recode = FALSE,
  clean = denormalize,
  api_key = NULL
)
```

## Arguments

- eleccion_id:

  Integer. The election ID.

- territorio_id:

  Integer. The territory ID.

- ...:

  Arguments after `...` must be named.

- denormalize:

  Logical. If `TRUE`, adds descriptive columns next to ID columns:
  `eleccion_descripcion`, `territorio_nombre` (in both
  `totales_territorio` and `votos_partido`), and `partido_nombre` (in
  `votos_partido`). Requires additional lookups. Default `FALSE`.

- use_recode:

  Logical. If `TRUE` and `denormalize = TRUE`, the `partido_nombre`
  column uses the recode group name (`agrupacion`) instead of the party
  abbreviation (`siglas`). Falls back to `siglas` when the party has no
  recode. Default `FALSE`.

- clean:

  Logical. If `TRUE`, removes ID and slug columns from both sub-tibbles.
  Defaults to the value of `denormalize`.

- api_key:

  (Opcional) Clave de API para sobrescribir la global solo en esta
  llamada.

## Value

A named list with two elements:

- `totales_territorio`:

  A 1-row tibble with summary fields: `id`, `eleccion_id`,
  `territorio_id`, `censo_ine`, `participacion_1`, `participacion_2`,
  `participacion_3`, `votos_validos`, `abstenciones`, `votos_blancos`,
  `votos_nulos`, `nrepresentantes`.

- `votos_partido`:

  A tibble of per-party votes, sorted by votes descending. Columns:
  `id`, `eleccion_id`, `territorio_id`, `partido_id`, `votos`,
  `representantes`, `partido_id`, `partido_siglas`,
  `partido_denominacion`, `partido_partido_recode_id`.

When `denormalize = TRUE`, additional columns `eleccion_descripcion`,
`territorio_nombre`, and `partido_nombre` (in `votos_partido`) are
inserted. When `clean = TRUE`, ID and slug columns are removed.

## Details

Party information is flattened into the votes tibble with prefixed
columns (`partido_id`, `partido_siglas`, `partido_denominacion`,
`partido_partido_recode_id`).

## Examples

``` r
if (FALSE) { # \dontrun{
result <- get_resultado_completo(208, 20)
result$totales_territorio
result$votos_partido

# With recode-based party names
result <- get_resultado_completo(208, 20,
    denormalize = TRUE, use_recode = TRUE
)
} # }
```
