# Autenticación: cómo establecer la API key

## Autenticación en EleccionesDB

La mayoría de los endpoints de la API requieren autenticación mediante
una API key personal.

### ¿Cómo obtengo mi API key?

1.  Regístrate en el [portal de
    desarrolladores](https://eleccionesdb-api.spainelectoralproject.com/developers/)
    de eleccionesdb y verifica tu email.
2.  Recibirás una clave personal que deberás usar en todas las
    peticiones protegidas.

### Establecer la clave como variable de entorno

La forma más segura y recomendada de usar tu clave es guardarla como
variable de entorno en tu archivo `~/.Renviron`.

Puedes registrar la clave solo para la sesión actual (o de forma
persistente) usando:

``` r

library(eleccionesdb)

# Solo para la sesión actual
db_set_api_key("TU_API_KEY")

# O de forma persistente (añade automáticamente a .Renviron)
edb_set_api_key("TU_API_KEY", persist = TRUE)
```

### Uso automático

Todas las funciones protegidas del paquete usarán la clave registrada
automáticamente. Si lo deseas, puedes sobrescribirla en una llamada
concreta:

``` r

get_partidos(siglas = "psoe", api_key = "OTRA_CLAVE")
```

### Seguridad

La clave nunca se imprime en consola ni se guarda en logs. Si olvidas
establecerla, recibirás un error claro indicando cómo hacerlo.
