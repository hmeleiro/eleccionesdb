# Configure the EleccionesDB data backend

Selects whether public query functions read from the remote API or from
a local SQLite snapshot. The setting applies only to the current R
session.

## Usage

``` r
edb_set_backend(backend = c("api", "sqlite"), path = NULL)
```

## Arguments

- backend:

  One of `"api"` or `"sqlite"`.

- path:

  Path to `eleccionesdb.sqlite`. When omitted,
  [`edb_sqlite_path()`](https://eleccionesdb-r.spainelectoralproject.com/reference/edb_sqlite_path.md)
  is used.

## Value

The previous backend configuration, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
edb_download_sqlite()
edb_set_backend("sqlite")
get_elecciones(tipo_eleccion = "G")
edb_set_backend("api")
} # }
```
