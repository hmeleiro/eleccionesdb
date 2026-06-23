# Backend SQLite

El backend SQLite permite ejecutar las mismas consultas del paquete
sobre un snapshot local. Es especialmente útil para resultados por
municipio o por sección, consultas repetidas y trabajo sin conexión. La
API continúa siendo el backend predeterminado y normalmente contiene los
datos más recientes.

## Instalación y descarga

``` r

install.packages(c("DBI", "RSQLite", "digest", "jsonlite"))
library(eleccionesdb)
edb_download_sqlite()
```

El paquete consulta primero un manifiesto pequeño. Si el SHA-256
instalado coincide con el remoto, no descarga otra vez el ZIP. La nueva
base se valida antes de sustituir la anterior, que se conserva ante
cualquier fallo.

El tamaño comprimido y descomprimido procede del manifiesto. Debe haber
espacio temporal para el ZIP, la base nueva y la instalación anterior.

## Activar SQLite

``` r

edb_set_backend("sqlite")
edb_get_backend()

resultados <- get_resultados(
  year = "2023",
  tipo_eleccion = "G",
  tipo_territorio = "municipio"
)

edb_set_backend("api")
```

La configuración solo afecta a la sesión actual.
[`get_health()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_health.md)
pertenece a la API: con SQLite activo avisa antes de usar la red. Los
errores de lectura, corrupción o esquema SQLite no hacen fallback, para
no ocultar problemas.

## Actualizaciones y rutas personalizadas

``` r

edb_check_sqlite_update()
edb_download_sqlite()
edb_download_sqlite(force = TRUE)

ruta <- "D:/datos/eleccionesdb.sqlite"
edb_download_sqlite(ruta)
edb_set_backend("sqlite", ruta)
```

La ubicación predeterminada se consulta con
[`edb_sqlite_path()`](https://eleccionesdb-r.spainelectoralproject.com/reference/edb_sqlite_path.md).
No se comprueban actualizaciones durante las consultas, por lo que una
instalación existente se puede utilizar completamente offline.

## Problemas habituales

- Si falta el archivo, descárgalo de nuevo o configura su ruta
  explícitamente.
- Si falta una dependencia opcional, instala los paquetes indicados en
  el error.
- Un esquema incompatible requiere actualizar el paquete o el snapshot.
- Para datos más recientes, cambia temporalmente a
  `edb_set_backend("api")`.
