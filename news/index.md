# Changelog

## eleccionesdb 0.1.0

- Añade `codigo_circunscripcion` a los resultados combinados y como
  filtro territorial en las funciones de resultados.
- Añade
  [`get_circunscripciones()`](https://eleccionesdb-r.spainelectoralproject.com/reference/get_circunscripciones.md)
  para consultar resultados por circunscripción.
- Añade un backend SQLite opcional para las consultas.
- Añade descarga y actualización segura mediante manifiestos SHA-256.
- Añade configuración por sesión y una guía de uso de SQLite.
