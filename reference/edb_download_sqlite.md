# Download or update the EleccionesDB SQLite snapshot

The archive and extracted database are verified with SHA-256 checksums.
The installed database is replaced only after all validation succeeds.

## Usage

``` r
edb_download_sqlite(path = NULL, force = FALSE)
```

## Arguments

- path:

  Destination SQLite path. Defaults to
  [`edb_sqlite_path()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_sqlite_path.md).

- force:

  Download even when the installed checksum is current.

## Value

The installed SQLite path, invisibly.
