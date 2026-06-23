# Introducción a eleccionesdb

## ¿Qué es eleccionesdb?

**eleccionesdb** es un cliente de R para la API REST de
[EleccionesDB](https://github.com/example/eleccionesdb-api), que da
acceso a datos electorales españoles. El paquete convierte las
respuestas JSON de la API en tibbles listas para analizar, gestiona la
paginación automáticamente y aplana estructuras anidadas de forma
inteligente.

## Instalación

``` r

# Desde fuente local
devtools::install_local("ruta/a/eleccionesdb")

# Cuando se publique en GitHub
# remotes::install_github("user/eleccionesdb")
```

## Verificar la conexión

Antes de empezar a trabajar, comprueba que la API está disponible:

``` r

get_health()
#> # A tibble: 1 × 3
#>   status environment database
#>   <chr>  <chr>       <chr>
#> 1 ok     production  ok
```

## Tipos de elección

España celebra cinco tipos de procesos electorales. Puedes consultarlos
con:

``` r

get_tipos_eleccion()
#> # A tibble: 5 × 2
#>   codigo descripcion
#>   <chr>  <chr>
#> 1 A      Autonomicas
#> 2 E      Europeas
#> 3 G      Congreso
#> 4 L      Locales
#> 5 S      Senado
```

Para obtener el detalle de un tipo concreto:

``` r

get_tipo_eleccion("G")
#> # A tibble: 1 × 2
#>   codigo descripcion
#>   <chr>  <chr>
#> 1 G      Congreso
```

## Listar elecciones

[`get_elecciones()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_elecciones.md)
devuelve un listado paginado de elecciones. Puedes filtrar por tipo,
año, mes y ámbito:

``` r

# Todas las elecciones generales
get_elecciones(tipo_eleccion = "G")
#> # A tibble: 16 × 9
#>       id tipo_eleccion year  mes   dia   fecha      descripcion       ambito   slug
#>    <int> <chr>         <chr> <chr> <chr> <date>     <chr>             <chr>    <chr>
#>  1   208 G             2019  04    28    2019-04-28 Elecciones Gene…  Nacional elecc…
#>  2   226 G             2019  11    10    2019-11-10 Elecciones Gene…  Nacional elecc…
#> # ℹ 14 more rows

# Elecciones generales de 2019
get_elecciones(tipo_eleccion = "G", year = "2019")

# Elecciones autonómicas de mayo
get_elecciones(tipo_eleccion = "A", mes = "05")
```

## Detalle de una elección

[`get_eleccion()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_eleccion.md)
devuelve una fila con los datos completos de una elección, incluyendo el
tipo expandido en columnas `tipo_codigo` y `tipo_descripcion`:

``` r

get_eleccion(208)
#> # A tibble: 1 × 10
#>      id tipo_eleccion year  mes   dia   fecha      descripcion      ambito   slug
#>   <int> <chr>         <chr> <chr> <chr> <date>     <chr>            <chr>    <chr>
#> 1   208 G             2019  04    28    2019-04-28 Elecciones Gen…  Nacional elecc…
#> # ℹ 1 more variable: tipo_codigo <chr>, tipo_descripcion <chr>
```

## Paginación

Todos los endpoints que devuelven listas soportan paginación con los
parámetros `limit` (máximo 500) y `skip`:

``` r

# Primeros 10 registros
get_elecciones(limit = 10)

# Saltar los primeros 50 y obtener los 20 siguientes
get_elecciones(limit = 20, skip = 50)
```

Para obtener **todos** los registros automáticamente (el paquete recorre
todas las páginas por ti), usa `all_pages = TRUE`:

``` r

todas <- get_elecciones(all_pages = TRUE)
nrow(todas)
#> [1] 254
```

Cada tibble devuelta incluye atributos con los metadatos de paginación:

``` r

tbl <- get_elecciones(tipo_eleccion = "G")
attr(tbl, "edb_total")
#> [1] 16
attr(tbl, "edb_skip")
#> [1] 0
attr(tbl, "edb_limit")
#> [1] 50
```

## Manejo de errores

El paquete traduce los errores de la API en mensajes claros:

``` r

# Recurso no encontrado (404)
get_eleccion(99999)
#> Error: API error (404): Elección no encontrada

# Error de validación (422)
get_elecciones(limit = -5)
#> Error: Error de validacion (422):
#> [query > limit] Input should be greater than or equal to 1

# Fallo de conexión
edb_set_base_url("http://servidor-inexistente:9999")
get_health()
#> Error: No se pudo conectar con la API de EleccionesDB.
#> ℹ URL base: http://servidor-inexistente:9999
#> ℹ Verifica que el servidor esta en ejecucion.
```

## Desnormalización de IDs

Las funciones de resultados devuelven columnas de ID (`eleccion_id`,
`territorio_id`, `partido_id`). Para añadir automáticamente nombres
descriptivos sin necesidad de hacer joins, usa `denormalize = TRUE`:

``` r

# Añade eleccion_descripcion, territorio_nombre y partido_nombre
get_votos_partido(
  eleccion_id = 208,
  territorio_id = 20,
  denormalize = TRUE
)
```

Si además quieres que el nombre del partido sea el de su agrupación
(recode), usa `use_recode = TRUE`:

``` r

# partido_nombre = agrupación del recode (ej. "PSOE" en vez de "P.S.O.E.")
get_votos_partido(
  eleccion_id = 208,
  territorio_id = 20,
  denormalize = TRUE,
  use_recode = TRUE
)
```

Más detalles y ejemplos en
[`vignette("analisis-resultados")`](https://eleccionesdb-r.spainelectoralproject.com/articles/analisis-resultados.md).

## Siguientes pasos

- **Territorios y partidos**: aprende a explorar la jerarquía
  territorial española y las agrupaciones de partidos en
  [`vignette("datos-maestros")`](https://eleccionesdb-r.spainelectoralproject.com/articles/datos-maestros.md).
- **Análisis de resultados**: flujos de trabajo completos con dplyr y
  ggplot2 en
  [`vignette("analisis-resultados")`](https://eleccionesdb-r.spainelectoralproject.com/articles/analisis-resultados.md).
- **Voto exterior (CERA)**: datos del Censo de Españoles Residentes
  Ausentes en
  [`vignette("voto-exterior-cera")`](https://eleccionesdb-r.spainelectoralproject.com/articles/voto-exterior-cera.md).
