# Análisis de resultados electorales

``` r

library(eleccionesdb)
library(dplyr)
library(tidyr)
library(ggplot2)
```

Este vignette muestra flujos de trabajo completos para analizar
resultados electorales españoles con **dplyr** y **ggplot2**, desde la
consulta de datos hasta la visualización.

------------------------------------------------------------------------

## Función principal: `get_resultados()`

[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
es la función central del paquete para análisis electoral. Devuelve un
tibble ancho que combina en una sola tabla:

- **Votos por partido**: `siglas`, `denominacion`, `partido_recode`,
  `partido_agrupacion`, `votos`, `representantes`
- **Totales territoriales**: `censo_ine`, `votos_validos`,
  `abstenciones`, `votos_blancos`, `votos_nulos`, `participacion_1`,
  `participacion_2`, `participacion_3`, `nrepresentantes`
- **Metadatos de elección y territorio**: `year`, `mes`,
  `tipo_eleccion`, `tipo_territorio`, `territorio_nombre`,
  `codigo_ccaa`, `codigo_provincia`, `codigo_municipio`,
  `codigo_distrito`, `codigo_seccion`

La unión de votos y totales se realiza internamente (no hace falta
ningún `join` manual). Por defecto, `clean = TRUE` renombra las columnas
y devuelve solo las más útiles para análisis.

``` r

# Resultados provinciales de Andalucía — Elecciones Generales abril 2019
andalucia <- get_resultados(
  tipo_eleccion = "G", year = "2019",
  tipo_territorio = "provincia",
  codigo_ccaa = "01",
  all_pages = TRUE
)

# Las 25 columnas listas para usar directamente:
names(andalucia)
#>  [1] "year"              "mes"               "tipo_eleccion"
#>  [4] "tipo_territorio"   "territorio_nombre" "codigo_ccaa"
#>  [7] "codigo_provincia"  "codigo_municipio"  "codigo_distrito"
#> [10] "codigo_seccion"    "censo_ine"         "votos_validos"
#> [13] "abstenciones"      "votos_blancos"     "votos_nulos"
#> [16] "participacion_1"   "participacion_2"   "participacion_3"
#> [19] "siglas"            "denominacion"      "partido_recode"
#> [22] "partido_agrupacion" "votos"            "representantes"
#> [25] "nrepresentantes"
```

### Atajos territoriales

Para los niveles más habituales existen funciones derivadas que evitan
tener que escribir `tipo_territorio` cada vez:

| Función | Equivale a |
|----|----|
| `get_ccaa(...)` | `get_resultados(..., tipo_territorio = "ccaa")` |
| `get_provincia(...)` | `get_resultados(..., tipo_territorio = "provincia")` |
| `get_municipios(...)` | `get_resultados(..., tipo_territorio = "municipio")` |
| `get_secciones(...)` | `get_resultados(..., tipo_territorio = "seccion")` |

``` r

# Equivalentes, misma salida:
get_ccaa(tipo_eleccion = "G", year = "2019", all_pages = TRUE)

get_resultados(tipo_eleccion = "G", year = "2019",
               tipo_territorio = "ccaa", all_pages = TRUE)
```

------------------------------------------------------------------------

## Otras funciones de resultados

Para casos de uso más específicos (control fino de paginación, datos con
IDs normalizados, joins con tablas propias), el paquete ofrece funciones
de acceso a bajo nivel:

| Función | Devuelve |
|----|----|
| [`get_totales_territorio_eleccion()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_totales_territorio_eleccion.md) | Totales territoriales de una elección concreta |
| [`get_resultado_completo()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultado_completo.md) | Lista con `$totales_territorio` + `$votos_partido` para una elección y territorio |
| [`get_totales_territorio()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_totales_territorio.md) | Totales territoriales filtrables (cruce de elecciones) |
| [`get_votos_partido()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_votos_partido.md) | Votos por partido filtrables (cruce de elecciones) |

Estas funciones devuelven IDs normalizados. Usa `denormalize = TRUE`
para añadir columnas descriptivas sin join manual:

``` r

# Sin desnormalizar: solo IDs
votos <- get_votos_partido(eleccion_id = 208, territorio_id = 20)
votos
#> # A tibble: 22 × 6
#>       id eleccion_id territorio_id partido_id votos representantes
#>    <int>       <int>         <int>      <int> <int>          <int>
#>  1 50001         208            20       9451 89432              3
#> ...

# Con desnormalización: columnas descriptivas insertadas junto a sus IDs
votos_dn <- get_votos_partido(
  eleccion_id = 208, territorio_id = 20,
  denormalize = TRUE
)
```

### Usar la agrupación (recode) como nombre del partido

``` r

# partido_nombre usa la agrupación del recode
votos_recode <- get_votos_partido(
  eleccion_id = 208,
  tipo_territorio = "provincia",
  all_pages = TRUE,
  denormalize = TRUE,
  use_recode = TRUE
)

# Ahora es fácil agrupar por partido sin joins adicionales
votos_recode |>
  group_by(partido_nombre) |>
  summarise(total = sum(votos), .groups = "drop") |>
  slice_max(total, n = 5)
#> # A tibble: 5 × 2
#>   partido_nombre     total
#>   <chr>              <int>
#> 1 PSOE             7480076
#> 2 AP/PP            4356646
#> 3 Cs               2692092
#> 4 UP               2381960
#> 5 VOX              2677173
```

------------------------------------------------------------------------

## 1. Resultados por nivel territorial

### Comunidades autónomas

``` r

# Resultados a nivel CCAA en las generales de abril 2019
ccaa_2019 <- get_ccaa(tipo_eleccion = "G", year = "2019", all_pages = TRUE)

# Comparar participación por CCAA (censo y votos ya incluidos en la misma tabla)
ccaa_2019 |>
  distinct(territorio_nombre, censo_ine, votos_validos) |>
  mutate(pct_participacion = round(votos_validos / censo_ine * 100, 1)) |>
  arrange(desc(pct_participacion))
#> # A tibble: 17 × 4
#>   territorio_nombre  censo_ine votos_validos pct_participacion
#>   <chr>                  <int>         <int>             <dbl>
#> 1 Pais Vasco           1847364       1374293              74.4
#> 2 Navarra               490123        354012              72.2
#> ...
```

### Provincias

``` r

# Votos por partido en las provincias de Andalucía
andalucia_prov <- get_provincia(
  tipo_eleccion = "G", year = "2019",
  codigo_ccaa = "01", all_pages = TRUE
)

# Top 3 partidos por provincia, con datos de censo ya incluidos
andalucia_prov |>
  filter(!is.na(partido_recode)) |>
  group_by(territorio_nombre) |>
  slice_max(votos, n = 3) |>
  select(territorio_nombre, partido_recode, votos, representantes,
         censo_ine, votos_validos)
```

### Municipios

``` r

# Resultados municipales en la provincia de Almería
almeria_mun <- get_municipios(
  tipo_eleccion = "G", year = "2019",
  codigo_provincia = "04", all_pages = TRUE
)

# Municipios con mayor abstención
almeria_mun |>
  distinct(territorio_nombre, censo_ine, abstenciones) |>
  mutate(pct_abstencion = round(abstenciones / censo_ine * 100, 1)) |>
  slice_max(pct_abstencion, n = 5) |>
  select(territorio_nombre, pct_abstencion, censo_ine)
```

### Secciones censales

``` r

# Datos por sección en un municipio (volumen alto: usar filtros siempre)
madrid_sec <- get_secciones(
  tipo_eleccion = "G", year = "2019",
  codigo_municipio = "2807900", all_pages = TRUE
)
```

------------------------------------------------------------------------

## 2. Análisis con resultados combinados

[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
y sus atajos territoriales combinan votos y totales territoriales en una
sola tabla lista para analizar con dplyr.

### Top 5 partidos por votos totales

``` r

# Trabajamos con los datos de Andalucía provinciales ya cargados
top5 <- andalucia_prov |>
  group_by(partido_recode) |>
  summarise(total_votos = sum(votos), .groups = "drop") |>
  filter(!is.na(partido_recode)) |>
  slice_max(total_votos, n = 5)

top5
#> # A tibble: 5 × 2
#>   partido_recode total_votos
#>   <chr>                <int>
#> 1 PSOE               1568432
#> 2 AP/PP              1023456
#> 3 Cs                  789012
#> 4 UP                  456789
#> 5 VOX                 345678
```

Para obtener los colores del recode, podemos consultar la tabla de
agrupaciones:

``` r

recodes <- get_partidos_recode(all_pages = TRUE)
colores <- recodes |>
  filter(agrupacion %in% top5$partido_recode) |>
  with(setNames(color, agrupacion))
```

### Gráfico de barras: votos por agrupación

``` r

ggplot(top5, aes(x = reorder(partido_recode, total_votos), y = total_votos)) +
  geom_col(aes(fill = partido_recode)) +
  scale_fill_manual(values = colores) +
  coord_flip() +
  scale_y_continuous(labels = scales::label_number(scale = 1e-6, suffix = "M")) +
  labs(
    title = "Elecciones Generales 28-A 2019 — Andalucía",
    subtitle = "Votos totales por agrupación (nivel provincia)",
    x = NULL,
    y = "Votos"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
```

### Votos por partido y provincia

``` r

# Desglose de los 5 principales partidos por provincia
por_provincia <- andalucia_prov |>
  filter(partido_recode %in% top5$partido_recode) |>
  select(territorio_nombre, partido_recode, votos)

por_provincia |>
  pivot_wider(
    names_from = partido_recode,
    values_from = votos,
    values_fill = 0
  )
```

### Gráfico: distribución provincial

``` r

ggplot(
  por_provincia,
  aes(x = territorio_nombre, y = votos, fill = partido_recode)
) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = colores) +
  scale_y_continuous(labels = scales::label_comma()) +
  labs(
    title = "Votos por partido y provincia — Andalucía 28-A 2019",
    x = NULL,
    y = "Votos",
    fill = "Agrupación"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

------------------------------------------------------------------------

## 3. Comparar participación entre elecciones

Con
[`get_ccaa()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_ccaa.md)
o `get_provincia()`, los datos de censo y participación ya están
incluidos en la misma tabla, por lo que no hace falta un join manual:

``` r

# Resultados a nivel CCAA para todas las generales
# (censo_ine y votos_validos ya incluidos en la misma tabla)
ccaa_generales <- get_ccaa(tipo_eleccion = "G", all_pages = TRUE)

# Calcular tasa de participación por elección y territorio en una sola operación
participacion <- ccaa_generales |>
  distinct(year, mes, territorio_nombre, censo_ine, votos_validos) |>
  mutate(tasa_participacion = votos_validos / censo_ine * 100)
```

### Gráfico: evolución de la participación

``` r

# Participación media nacional por elección
media_nacional <- participacion |>
  group_by(year) |>
  summarise(media_participacion = mean(tasa_participacion, na.rm = TRUE))

ggplot(media_nacional, aes(x = year, y = media_participacion, group = 1)) +
  geom_line(linewidth = 1, color = "#333333") +
  geom_point(size = 3, color = "#E30613") +
  scale_y_continuous(limits = c(50, 85), labels = function(x) paste0(x, "%")) +
  labs(
    title = "Evolución de la participación en elecciones generales",
    x = NULL,
    y = "Participación media (%)"
  ) +
  theme_minimal()
```

------------------------------------------------------------------------

## 4. Evolución del voto de una agrupación

Con `get_provincia()` (o
[`get_ccaa()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_ccaa.md))
se obtienen votos y metadatos de elección en la misma tabla, por lo que
el análisis temporal no requiere joins:

``` r

# Total nacional por agrupación y año en elecciones generales
evolucion <- get_provincia(tipo_eleccion = "G", all_pages = TRUE) |>
  filter(!is.na(partido_recode)) |>
  group_by(year, partido_recode) |>
  summarise(total_votos = sum(votos), .groups = "drop")
```

### Gráfico: evolución temporal de los principales partidos

``` r

# Seleccionar las 4 agrupaciones con más votos históricos
top_agrupaciones <- evolucion |>
  group_by(partido_recode) |>
  summarise(total = sum(total_votos)) |>
  slice_max(total, n = 4)

# Obtener colores de las agrupaciones
recodes_colores <- get_partidos_recode(all_pages = TRUE)
colores_top <- recodes_colores |>
  filter(agrupacion %in% top_agrupaciones$partido_recode) |>
  with(setNames(color, agrupacion))

evolucion |>
  filter(partido_recode %in% top_agrupaciones$partido_recode) |>
  ggplot(aes(x = year, y = total_votos, color = partido_recode, group = partido_recode)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = colores_top) +
  scale_y_continuous(labels = scales::label_number(scale = 1e-6, suffix = "M")) +
  labs(
    title = "Evolución del voto en elecciones generales",
    subtitle = "Total nacional por agrupación (nivel provincia)",
    x = NULL,
    y = "Votos totales",
    color = "Agrupación"
  ) +
  theme_minimal()
```

------------------------------------------------------------------------

## 5. Mapa de calor: representantes por provincia

``` r

# Representantes por provincia y agrupación en las generales 28-A 2019
representantes <- get_provincia(
  tipo_eleccion = "G", year = "2019",
  all_pages = TRUE
) |>
  filter(partido_recode %in% c("PSOE", "AP/PP", "Cs", "UP", "VOX")) |>
  select(territorio_nombre, partido_recode, representantes)

ggplot(representantes, aes(
  x = partido_recode,
  y = territorio_nombre,
  fill = representantes
)) +
  geom_tile(color = "white") +
  scale_fill_viridis_c(option = "plasma", direction = -1) +
  labs(
    title = "Representantes por provincia — 28-A 2019",
    x = NULL,
    y = NULL,
    fill = "Escaños"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

------------------------------------------------------------------------

## Siguientes pasos

- **Introducción**: si aún no lo has leído, repasa los conceptos básicos
  en
  [`vignette("introduccion")`](https://hmeleiro.github.io/eleccionesdb-r/articles/introduccion.md).
- **Territorios y partidos**: profundiza en los datos maestros en
  [`vignette("datos-maestros")`](https://hmeleiro.github.io/eleccionesdb-r/articles/datos-maestros.md).
- **Voto exterior (CERA)**: analiza el voto de los españoles en el
  extranjero en
  [`vignette("voto-exterior-cera")`](https://hmeleiro.github.io/eleccionesdb-r/articles/voto-exterior-cera.md).
