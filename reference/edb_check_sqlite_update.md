# Check whether a newer SQLite snapshot is available

Downloads only the small remote manifest and compares it with the
locally installed snapshot.

## Usage

``` r
edb_check_sqlite_update(path = NULL)
```

## Arguments

- path:

  Destination SQLite path. Defaults to
  [`edb_sqlite_path()`](https://eleccionesdb-r.spainelectoralproject.com/reference/edb_sqlite_path.md).

## Value

A one-row tibble describing the local and remote versions.
