# Voto exterior (CERA)

``` r

library(eleccionesdb)
library(dplyr)
library(ggplot2)
```

## ¿Qué es el CERA?

El **CERA** (Censo de Españoles Residentes Ausentes) recoge los datos de
participación y voto de los ciudadanos españoles que residen en el
extranjero. Estos votos se contabilizan de forma separada al voto
nacional y se gestionan a través de circunscripciones específicas.

El paquete **eleccionesdb** ofrece dos funciones para acceder a estos
datos:

| Función | Devuelve |
|----|----|
| [`get_cera_resumen()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_cera_resumen.md) | Resúmenes de participación CERA (censo, votos válidos, abstenciones…) |
| [`get_cera_votos()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_cera_votos.md) | Votos por partido en el exterior |

Ambas funciones soportan paginación (`limit`, `skip`, `all_pages`) y los
mismos filtros cruzados que los endpoints de resultados nacionales.

Además, ambas funciones soportan el parámetro `denormalize = TRUE` para
añadir columnas descriptivas (`eleccion_descripcion`,
`territorio_nombre`) junto a las columnas de ID.
[`get_cera_votos()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_cera_votos.md)
acepta además `use_recode = TRUE` para que `partido_nombre` use la
agrupación del recode.

------------------------------------------------------------------------

## Resúmenes de participación CERA

[`get_cera_resumen()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_cera_resumen.md)
devuelve datos agregados de participación del voto exterior: censo,
participación, votos válidos, nulos, en blanco y abstenciones.

``` r

# Resúmenes CERA de todas las elecciones generales
cera_generales <- get_cera_resumen(
  tipo_eleccion = "G",
  all_pages = TRUE
)
cera_generales
#> # A tibble: 128 × 11
#>       id eleccion_id territorio_id censo_ine participacion_1 participacion_2
#>    <int>       <int>         <int>     <int>           <int>           <int>
#>  1 20001         208          5001     32456           12345           14567
#>  2 20002         208          5002     18234            7890            9012
#> # ℹ 126 more rows
#> # ℹ 5 more variables: participacion_3 <int>, votos_validos <int>,
#> #   votos_nulos <int>, votos_blanco <int>, nrepresentantes <int>
```

### Filtrar por elección

``` r

# CERA para las generales de abril 2019
cera_28a <- get_cera_resumen(eleccion_id = 208, all_pages = TRUE)
cera_28a
```

### Filtrar por año

``` r

# Todos los CERA de 2019 (abril y noviembre)
cera_2019 <- get_cera_resumen(year = "2019", all_pages = TRUE)
```

------------------------------------------------------------------------

## Votos por partido en el exterior

[`get_cera_votos()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_cera_votos.md)
devuelve el desglose de votos por partido en las circunscripciones CERA:

``` r

# Votos CERA de las generales de abril 2019
votos_cera <- get_cera_votos(
  eleccion_id = 208,
  all_pages = TRUE
)
votos_cera
#> # A tibble: 320 × 6
#>       id eleccion_id territorio_id partido_id votos representantes
#>    <int>       <int>         <int>      <int> <int>          <int>
#>  1 30001         208          5001       9451  4567              0
#>  2 30002         208          5001       3421  3210              0
#> # ℹ 318 more rows
```

### Filtrar por partido

``` r

# Votos CERA de un partido concreto en todas las elecciones
votos_psoe_cera <- get_cera_votos(
  partido_id = 9451,
  tipo_eleccion = "G",
  all_pages = TRUE
)
```

------------------------------------------------------------------------

## Ejemplo: tasa de participación CERA vs. nacional

Podemos comparar la participación del voto exterior con la participación
nacional en una misma elección:

``` r

elec_id <- 208

# Participación nacional (a nivel de CCAA)
nacional <- get_totales_territorio(
  eleccion_id = elec_id,
  tipo_territorio = "ccaa",
  all_pages = TRUE
) |>
  summarise(
    censo = sum(censo_ine),
    participacion = sum(participacion_1)
  ) |>
  mutate(
    tipo = "Nacional",
    tasa = participacion / censo * 100
  )

# Participación CERA
cera <- get_cera_resumen(
  eleccion_id = elec_id,
  all_pages = TRUE
) |>
  summarise(
    censo = sum(censo_ine),
    participacion = sum(participacion_1)
  ) |>
  mutate(
    tipo = "CERA",
    tasa = participacion / censo * 100
  )

comparativa <- bind_rows(nacional, cera)
comparativa
#> # A tibble: 2 × 4
#>       censo participacion tipo      tasa
#>       <int>         <int> <chr>    <dbl>
#> 1  34872054      25020000 Nacional  71.7
#> 2   2102345        234567 CERA      11.2
```

### Gráfico comparativo

``` r

ggplot(comparativa, aes(x = tipo, y = tasa, fill = tipo)) +
  geom_col(width = 0.5) +
  geom_text(aes(label = sprintf("%.1f%%", tasa)), vjust = -0.5, size = 5) +
  scale_fill_manual(values = c("Nacional" = "#333333", "CERA" = "#E30613")) +
  scale_y_continuous(limits = c(0, 100), labels = function(x) paste0(x, "%")) +
  labs(
    title = "Participación: Nacional vs. CERA",
    subtitle = "Elecciones Generales 28-A 2019",
    x = NULL,
    y = "Tasa de participación"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
```

------------------------------------------------------------------------

## Ejemplo: distribución del voto CERA por partido

Con `denormalize = TRUE` y `use_recode = TRUE`, podemos obtener los
nombres de partido directamente, sin necesidad de hacer joins manuales:

``` r

# Votos CERA con nombres de partido (usando agrupación recode)
votos_cera <- get_cera_votos(
  eleccion_id = 208,
  all_pages = TRUE,
  denormalize = TRUE,
  use_recode = TRUE
)

# Agregar votos por partido_nombre (ya contiene la agrupación)
totales_cera <- votos_cera |>
  group_by(partido_nombre) |>
  summarise(total_votos = sum(votos), .groups = "drop") |>
  filter(!is.na(partido_nombre)) |>
  slice_max(total_votos, n = 6)

totales_cera
```

También se puede enriquecer con colores obteniendo el recode por
separado:

``` r

# Obtener colores de las agrupaciones principales
recodes <- get_partidos_recode(all_pages = TRUE)
resultado_cera <- totales_cera |>
  left_join(
    recodes |> select(agrupacion, color),
    by = c("partido_nombre" = "agrupacion")
  )
resultado_cera
```

### Gráfico: votos CERA por partido

``` r

colores_cera <- setNames(resultado_cera$color, resultado_cera$partido_nombre)

ggplot(resultado_cera, aes(
  x = reorder(partido_nombre, total_votos),
  y = total_votos,
  fill = partido_nombre
)) +
  geom_col() +
  scale_fill_manual(values = colores_cera) +
  coord_flip() +
  scale_y_continuous(labels = scales::label_comma()) +
  labs(
    title = "Voto exterior (CERA) por agrupación — 28-A 2019",
    x = NULL,
    y = "Votos totales"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
```

------------------------------------------------------------------------

## Ejemplo: evolución del voto CERA a lo largo del tiempo

``` r

# Resúmenes CERA de todas las generales
cera_historico <- get_cera_resumen(
  tipo_eleccion = "G",
  all_pages = TRUE
)

# Agregar por elección
evolucion_cera <- cera_historico |>
  group_by(eleccion_id) |>
  summarise(
    censo = sum(censo_ine),
    participacion = sum(participacion_1),
    .groups = "drop"
  ) |>
  mutate(tasa = participacion / censo * 100)

# Enriquecer con fecha de la elección
elecciones <- get_elecciones(tipo_eleccion = "G", all_pages = TRUE)

evolucion_cera <- evolucion_cera |>
  left_join(
    elecciones |> select(id, fecha),
    by = c("eleccion_id" = "id")
  )
```

### Gráfico: evolución temporal

``` r

ggplot(evolucion_cera, aes(x = fecha, y = tasa)) +
  geom_line(linewidth = 1, color = "#E30613") +
  geom_point(size = 3, color = "#E30613") +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title = "Evolución de la participación CERA en elecciones generales",
    x = NULL,
    y = "Tasa de participación (%)"
  ) +
  theme_minimal()
```

------------------------------------------------------------------------

## Referencia rápida de filtros CERA

Ambas funciones
([`get_cera_resumen()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_cera_resumen.md)
y
[`get_cera_votos()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_cera_votos.md))
aceptan estos parámetros de filtro:

| Parámetro       | Tipo      | Descripción                       |
|-----------------|-----------|-----------------------------------|
| `eleccion_id`   | integer   | Filtrar por ID de elección        |
| `territorio_id` | integer   | Filtrar por territorio CERA       |
| `year`          | character | Año de la elección (ej. `"2019"`) |
| `tipo_eleccion` | character | Código de tipo (ej. `"G"`, `"E"`) |

Además,
[`get_cera_votos()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_cera_votos.md)
acepta:

| Parámetro    | Tipo    | Descripción               |
|--------------|---------|---------------------------|
| `partido_id` | integer | Filtrar por ID de partido |

### Parámetros de desnormalización

Ambas funciones aceptan `denormalize = TRUE` para añadir columnas
descriptivas.
[`get_cera_votos()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_cera_votos.md)
acepta además `use_recode = TRUE`:

| Parámetro | Funciones | Descripción |
|----|----|----|
| `denormalize` | Ambas | Añade `eleccion_descripcion` y `territorio_nombre` |
| `use_recode` | [`get_cera_votos()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_cera_votos.md) | `partido_nombre` usa la agrupación del recode |

------------------------------------------------------------------------

## Otros vignettes

- **Introducción**: conceptos básicos y configuración en
  [`vignette("introduccion")`](https://eleccionesdb-r.spainelectoralproject.com/articles/introduccion.md).
- **Territorios y partidos**: datos maestros en
  [`vignette("datos-maestros")`](https://eleccionesdb-r.spainelectoralproject.com/articles/datos-maestros.md).
- **Análisis de resultados**: flujos completos con dplyr y ggplot2 en
  [`vignette("analisis-resultados")`](https://eleccionesdb-r.spainelectoralproject.com/articles/analisis-resultados.md).
