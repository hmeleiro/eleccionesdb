# Territorios y partidos

``` r

library(eleccionesdb)
library(dplyr)
```

Este vignette explica cómo explorar las dos entidades maestras de la
base de datos: **territorios** (la jerarquía territorial española) y
**partidos** (incluyendo sus agrupaciones o *recode*).

------------------------------------------------------------------------

## Territorios

### Jerarquía territorial

Los territorios en EleccionesDB se organizan en una jerarquía de 7
niveles:

| Tipo              | Descripción               | Ejemplo                |
|-------------------|---------------------------|------------------------|
| `ccaa`            | Comunidad Autónoma        | Andalucía, Cataluña    |
| `provincia`       | Provincia                 | Sevilla, Barcelona     |
| `municipio`       | Municipio                 | Dos Hermanas, Badalona |
| `distrito`        | Distrito censal           | —                      |
| `seccion`         | Sección censal            | —                      |
| `circunscripcion` | Circunscripción electoral | —                      |
| `cera`            | Voto exterior (CERA)      | —                      |

Cada territorio contiene códigos jerárquicos completos (`codigo_ccaa`,
`codigo_provincia`, `codigo_municipio`, etc.) y un `parent_id` que
permite navegar hacia arriba en la jerarquía.

### Listar territorios

[`get_territorios()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_territorios.md)
devuelve un listado paginado que puedes filtrar por tipo, códigos
jerárquicos y nombre:

``` r

# Todas las comunidades autónomas
ccaas <- get_territorios(tipo = "ccaa", all_pages = TRUE)
ccaas
#> # A tibble: 19 × 5
#>       id tipo  nombre             codigo_completo parent_id
#>    <int> <chr> <chr>              <chr>               <int>
#>  1     1 ccaa  Andalucia          0100000000000          NA
#>  2     2 ccaa  Aragon             0200000000000          NA
#>  3     3 ccaa  Asturias           0300000000000          NA
#> # ℹ 16 more rows
```

``` r

# Provincias de Andalucía (codigo_ccaa = "01")
provincias_andalucia <- get_territorios(
  tipo = "provincia",
  codigo_ccaa = "01",
  all_pages = TRUE
)
provincias_andalucia
#> # A tibble: 8 × 5
#>       id tipo      nombre   codigo_completo parent_id
#>    <int> <chr>     <chr>    <chr>               <int>
#>  1    20 provincia Almeria  0104000000000           1
#>  2    21 provincia Cadiz    0111000000000           1
#>  3    22 provincia Cordoba  0114000000000           1
#> # ℹ 5 more rows
```

``` r

# Buscar por nombre (búsqueda parcial)
get_territorios(nombre = "madrid")
#> # A tibble: 50 × 5
#>       id tipo      nombre               codigo_completo parent_id
#>    <int> <chr>     <chr>                 <chr>               <int>
#>  1    13 ccaa      Madrid               1300000000000          NA
#>  2    50 provincia Madrid               1328000000000          13
#>  3   812 municipio Madrid               1328079000000          50
#> # ℹ 47 more rows
```

### Detalle de un territorio

[`get_territorio()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_territorio.md)
devuelve todos los códigos jerárquicos de un territorio:

``` r

# Detalle de la provincia de Sevilla
get_territorio(27)
#> # A tibble: 1 × 12
#>      id tipo      nombre  codigo_ccaa codigo_provincia codigo_municipio
#>   <int> <chr>     <chr>   <chr>       <chr>            <chr>
#> 1    27 provincia Sevilla 01          41               000
#> # ℹ 6 more variables: codigo_distrito <chr>, codigo_seccion <chr>,
#> #   codigo_circunscripcion <chr>, codigo_completo <chr>, parent_id <int>
```

### Navegar la jerarquía

[`get_territorio_hijos()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_territorio_hijos.md)
devuelve los hijos directos de un territorio, permitiendo recorrer la
jerarquía de arriba a abajo:

``` r

# Hijos de Andalucía (id = 1) → sus 8 provincias
provincias <- get_territorio_hijos(1, all_pages = TRUE)
provincias
#> # A tibble: 8 × 5
#>       id tipo      nombre     codigo_completo parent_id
#>    <int> <chr>     <chr>      <chr>               <int>
#>  1    20 provincia Almeria    0104000000000           1
#>  2    21 provincia Cadiz      0111000000000           1
#>  3    22 provincia Cordoba    0114000000000           1
#>  4    23 provincia Granada    0118000000000           1
#>  5    24 provincia Huelva     0121000000000           1
#>  6    25 provincia Jaen       0123000000000           1
#>  7    26 provincia Malaga     0129000000000           1
#>  8    27 provincia Sevilla    0141000000000           1
```

``` r

# Municipios de la provincia de Sevilla (id = 27)
municipios_sevilla <- get_territorio_hijos(27, all_pages = TRUE)
nrow(municipios_sevilla)
#> [1] 105
head(municipios_sevilla)
#> # A tibble: 6 × 5
#>      id tipo      nombre            codigo_completo parent_id
#>   <int> <chr>     <chr>             <chr>               <int>
#> 1  5401 municipio Aguadulce         0141001000000          27
#> 2  5402 municipio Alanis            0141002000000          27
#> 3  5403 municipio Albaida del Ala…  0141003000000          27
#> # ℹ 3 more rows
```

#### Ejemplo: recorrer la jerarquía completa

``` r

# Obtener todas las CCAAs y contar sus provincias
ccaas <- get_territorios(tipo = "ccaa", all_pages = TRUE)

resumen_provincias <- lapply(ccaas$id, function(ccaa_id) {
  hijos <- get_territorio_hijos(ccaa_id, all_pages = TRUE)
  tibble(
    ccaa_id = ccaa_id,
    n_provincias = nrow(hijos)
  )
}) |> bind_rows()

resumen_provincias <- left_join(
  ccaas |> select(id, nombre),
  resumen_provincias,
  by = c("id" = "ccaa_id")
)
resumen_provincias
```

------------------------------------------------------------------------

## Partidos

### Buscar partidos

[`get_partidos()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_partidos.md)
permite buscar partidos por siglas, denominación o por su grupo de
recode:

``` r

# Buscar partidos con siglas "PSOE"
get_partidos(siglas = "psoe")
#> # A tibble: 50 × 4
#>       id siglas              denominacion                      partido_recode_id
#>    <int> <chr>               <chr>                                         <int>
#>  1  9451 P.S.O.E.            PARTIDO SOCIALISTA OBRERO ESPAÑOL                80
#>  2  9452 P.S.O.E.-PROGRE…    PARTIDO SOCIALISTA OBRERO ESPAÑOL…               80
#>  3  9453 P.S.O.E.-P.S.C.     PARTIDO SOCIALISTA OBRERO ESPAÑOL…               80
#> # ℹ 47 more rows
```

``` r

# Buscar por denominación
get_partidos(denominacion = "popular", limit = 5)

# Buscar partidos de un grupo de recode concreto
get_partidos(partido_recode_id = 80, all_pages = TRUE)
```

### Detalle de un partido

[`get_partido()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_partido.md)
devuelve el detalle completo de un partido, con los datos del recode
expandidos como columnas con prefijo `recode_`:

``` r

get_partido(9451)
#> # A tibble: 1 × 7
#>      id siglas   denominacion                      partido_recode_id recode_id
#>   <int> <chr>    <chr>                                         <int>     <int>
#> 1  9451 P.S.O.E. PARTIDO SOCIALISTA OBRERO ESPAÑOL                80        80
#> # ℹ 2 more variables: recode_agrupacion <chr>, recode_color <chr>
```

Los partidos sin grupo de recode asignado tendrán
`partido_recode_id = NA` y las columnas `recode_*` también serán `NA`.

### Agrupaciones de partidos (recode)

Los partidos se agrupan en **familias** (recode) que permiten agregar
votos de partidos locales o coaliciones bajo un mismo paraguas. Por
ejemplo, las distintas candidaturas del PSOE en cada comunidad autónoma
se agrupan bajo el recode “PSOE”.

``` r

# Listar agrupaciones
get_partidos_recode()
#> # A tibble: 50 × 4
#>       id partido_recode    agrupacion color
#>    <int> <chr>             <chr>      <chr>
#>  1     1 AP/PP             AP/PP      #0068B2
#>  2     2 BNG               BNG        #76B3DD
#>  3     3 CC                CC         #FFD700
#> # ℹ 47 more rows
```

``` r

# Buscar por agrupación
get_partidos_recode(agrupacion = "izquierda")
```

### Detalle de una agrupación

[`get_partido_recode()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_partido_recode.md)
devuelve una **lista** con dos elementos:

- `$recode` — tibble de 1 fila con la información del grupo.
- `$partidos` — tibble con todos los partidos miembros.

Se usa una lista porque un grupo puede contener cientos o miles de
partidos:

``` r

resultado <- get_partido_recode(80)

# Información del grupo
resultado$recode
#> # A tibble: 1 × 4
#>      id partido_recode agrupacion color
#>   <int> <chr>          <chr>      <chr>
#> 1    80 PSOE           PSOE       #E30613

# Partidos miembros
nrow(resultado$partidos)
#> [1] 342

head(resultado$partidos)
#> # A tibble: 6 × 4
#>      id siglas              denominacion                      partido_recode_id
#>   <int> <chr>               <chr>                                         <int>
#> 1  9451 P.S.O.E.            PARTIDO SOCIALISTA OBRERO ESPAÑOL                80
#> 2  9452 P.S.O.E.-PROGRE…    PARTIDO SOCIALISTA OBRERO ESPAÑOL…               80
#> 3  9453 P.S.O.E.-P.S.C.     PARTIDO SOCIALISTA OBRERO ESPAÑOL…               80
#> # ℹ 3 more rows
```

#### Ejemplo: explorar las familias más grandes

``` r

recodes <- get_partidos_recode(all_pages = TRUE)

# Para cada agrupación, contar cuántos partidos incluye
tamanos <- lapply(recodes$id, function(recode_id) {
  detalle <- get_partido_recode(recode_id)
  tibble(
    recode_id = recode_id,
    agrupacion = detalle$recode$agrupacion,
    n_partidos = nrow(detalle$partidos)
  )
}) |> bind_rows()

tamanos |>
  arrange(desc(n_partidos)) |>
  head(10)
```

------------------------------------------------------------------------

### Siguientes pasos

- **Análisis de resultados**: aprende a combinar estos datos maestros
  con resultados electorales en
  [`vignette("analisis-resultados")`](https://hmeleiro.github.io/eleccionesdb-r/articles/analisis-resultados.md).
- **Voto exterior (CERA)**: datos del Censo de Españoles Residentes
  Ausentes en
  [`vignette("voto-exterior-cera")`](https://hmeleiro.github.io/eleccionesdb-r/articles/voto-exterior-cera.md).
