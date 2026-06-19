# Despliegue propio de la base de datos y la API

## Introducción

Por defecto, **eleccionesdb** se conecta a la API pública de Spain
Electoral Project (`https://api.spainelectoralproject.com/`). Sin
embargo, si necesitas más control —por ejemplo, mayor rendimiento,
acceso sin límites de tasa, o datos adicionales propios— puedes levantar
tu propia instancia de la base de datos PostgreSQL y la API REST.

Este artículo explica cómo hacerlo y cómo configurar el paquete para que
apunte a tu servidor.

## Componentes del stack

El proyecto se compone de dos piezas que puedes desplegar de forma
independiente:

| Componente | Descripción | Documentación |
|----|----|----|
| **eleccionesdb-etl** | Pipeline ETL (R + {targets}) que genera la base de datos PostgreSQL a partir de datos electorales en bruto. | [Documentación](https://eleccionesdb.spainelectoralproject.com/) |
| **eleccionesdb-api** | API REST (Python + FastAPI) que expone la base de datos como endpoints JSON. | [Documentación](https://eleccionesdb-api.spainelectoralproject.com/) |

## Paso 1: Levantar la base de datos

El repositorio
[eleccionesdb-etl](https://eleccionesdb.spainelectoralproject.com/)
contiene un pipeline reproducible que descarga datos electorales
oficiales, los transforma y los carga en una base PostgreSQL.

``` bash
# Clonar el repositorio
git clone https://github.com/hmeleiro/eleccionesdb-etl.git
cd eleccionesdb-etl

# Crear un archivo .env con las credenciales de tu Postgres
cat > .env <<EOF
DB_NAME=eleccionesdb
DB_HOST=localhost
DB_PORT=5432
DB_USER=mi_usuario
DB_PASSWORD=mi_password
EOF

# Ejecutar el pipeline desde R
Rscript -e "source('run.R'); run_all()"
```

Consulta la [documentación completa del
ETL](https://eleccionesdb.spainelectoralproject.com/) para requisitos
previos (PostgreSQL, paquetes R) y opciones avanzadas.

## Paso 2: Levantar la API

El repositorio
[eleccionesdb-api](https://eleccionesdb-api.spainelectoralproject.com/)
proporciona una API REST lista para producción construida con FastAPI.

La forma más sencilla de desplegarla es con Docker:

``` bash
# Clonar el repositorio
git clone https://github.com/hmeleiro/eleccionesdb-api.git
cd eleccionesdb-api

# Configurar las variables de entorno (mismas credenciales que el ETL)
cp .env.example .env
# Editar .env con tus credenciales

# Levantar con Docker Compose
docker compose up -d
```

La API estará disponible en `http://localhost:8000`. Puedes verificarlo
con:

``` bash
curl http://localhost:8000/health
# {"status":"ok","environment":"production","database":"ok"}
```

Consulta la [documentación completa de la
API](https://eleccionesdb-api.spainelectoralproject.com/) para opciones
de configuración, autenticación y despliegue en la nube.

## Paso 3: Configurar eleccionesdb

Una vez que tu API esté funcionando, configura el paquete para que
apunte a ella:

``` r

library(eleccionesdb)

# Opción 1: variable de entorno (recomendado para uso habitual)
# Añade a tu .Renviron:
#   ELECCIONESDB_URL=http://mi-servidor:8000
# y reinicia R. El paquete lo detectará automáticamente.

# Opción 2: en tiempo de ejecución
edb_set_base_url("http://mi-servidor:8000")
```

Puedes verificar la conexión en cualquier momento:

``` r

# Comprobar a qué URL apunta el paquete
edb_get_base_url()
#> [1] "http://mi-servidor:8000"

# Verificar que la API responde
get_health()
#> # A tibble: 1 × 3
#>   status environment database
#>   <chr>  <chr>       <chr>
#> 1 ok     production  ok
```

A partir de aquí, todas las funciones del paquete
([`get_elecciones()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_elecciones.md),
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md),
etc.) usarán tu instancia de la API.

## Volver a la API pública

Para volver a usar la API pública de Spain Electoral Project:

``` r

edb_set_base_url("https://api.spainelectoralproject.com")
```
