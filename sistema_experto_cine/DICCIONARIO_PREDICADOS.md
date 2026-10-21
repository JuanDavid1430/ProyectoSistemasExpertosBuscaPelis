# Diccionario de predicados de CineExperto

**Convención de modos:** `+` entrada instanciada, `-` salida derivada, `?` entrada o salida. Los predicados de búsqueda se diseñaron para recibir desde Python una consulta ya instanciada y opcionalmente una edad.

## Hechos (todos estructurados con aridad >= 2)

| Predicado / aridad | Modo | Descripción |
|---|---|---|
| `pelicula/3` | `?Id, ?Titulo, ?Anio` | Catálogo y metadatos básicos. |
| `genero/2` | `?Id, ?Genero` | Género editorial, separado de las opiniones. |
| `etiqueta/2` | `?Id, ?Etiqueta` | Etiquetas oficiales del catálogo local. |
| `edad_minima/2` | `?Id, ?Edad` | Edad mínima ilustrativa del prototipo. |
| `sinopsis/2` | `?Id, ?Texto` | Texto descriptivo de la película. |
| `tema_sinopsis/2` | `?Id, ?Tema` | Índice temático manual derivado de la sinopsis. |
| `opinion/4` | `?Id, ?Autor, ?Texto, ?Percepcion` | Reseña ficticia y su categoría perceptiva. |
| `sinonimo/2` | `?Token, ?Criterio` | Vocabulario de consultas admitidas. |

## Reglas de inferencia y sus niveles

| Firma | Modo de instanciación | Nivel | Función |
|---|---|---|---|
| `pelicula_valida/1` | `?P` | 1 | Identifica películas registradas. |
| `genero_validado/2` | `?P, ?G` | 1 | Valida género contra película existente. |
| `etiqueta_validada/2` | `?P, ?E` | 1 | Valida etiqueta editorial. |
| `tema_validado/2` | `?P, ?T` | 1 | Exige sinopsis y tema indexado. |
| `edad_valida/2` | `?P, ?Edad` | 1 | Revisa edad mínima registrada. |
| `edad_compatible/2` | `?P, +Edad` | 1 | Comprueba que el espectador cumpla la edad mínima. |
| `edad_habilitada/2` | `+P, +Edad` | 1 | Permite edad `-1` (sin filtro) o verifica edad. Usa corte. |
| `opinion_validada/3` | `?P, ?Autor, ?Tema` | 1 | Verifica atribución de la reseña. |
| `contenido_de_terror/1` | `?P` | 1 | Detecta género terror para una regla de exclusión. |
| `orientacion_infantil/1` | `?P` | 2 | Busca etiqueta infantil o familiar. |
| `percepcion_recurrente/3` | `?P, +Tema, -Total` | 2 | Reúne revisores con `findall`, quita duplicados y exige mínimo dos. |
| `apta_para_ninos/1` | `?P` | 2 | Combina edad <= 10, orientación y `\+ contenido_de_terror`. |
| `coincidencia_genero/4` | `?P, +C, -Fuente, -Motivo` | 2 | Evidencia por género. |
| `coincidencia_etiqueta/4` | `?P, +C, -Fuente, -Motivo` | 2 | Evidencia por etiqueta. |
| `coincidencia_sinopsis/4` | `?P, +C, -Fuente, -Motivo` | 2 | Evidencia por tema indexado. |
| `coincidencia_opinion/4` | `?P, +C, -Fuente, -Motivo` | 2 | Evidencia por dos o más autores, sin reclasificar género. |
| `coincidencia_infantil/4` | `?P, +infantil, -Fuente, -Motivo` | 2 | Filtra por aptitud infantil. |
| `coincidencia/4` | `?P, +C, -Fuente, -Motivo` | 3 | Une cinco formas de coincidencia. |
| `puntaje_fuente/2` | `+Fuente, -Puntos` | 3 | Prioridad numérica por fuente; usa cortes y fallback. |
| `prioridad_de_puntaje/2` | `+Puntos, -Prioridad` | 3 | Clasifica relevancia en alta/media/baja. |
| `evidencia/3` | `?P, +C, -Evidencia` | 3 | Construye término de evidencia con puntaje. |
| `mejor_evidencia/2` | `+Lista, -Mejor` | 3 | Selecciona mayor puntaje de lista finita. |
| `mejor_aux/3` | `+Resto, +Acumulada, -Mejor` | 3 | Recorre la lista de forma estructural y terminante. |
| `evidencia_dict/2` | `+Evidencia, -Dict` | 3 | Transforma explicación a diccionario exportable. |
| `resultado_para/3` | `+Criterios, +P, -Resultado` | 3 | Agrega ficha, evidencia, mejor fuente y prioridad. |
| `criterio_admisible/2` | `+P, +C` | 3 | Exige aptitud infantil para búsquedas infantiles y género editorial terror para búsquedas de terror. |
| `buscar_peliculas/3` | `+Criterios, +Edad, -Resultados` | 3 | Consulta central, `findall`, `sort`, ranking descendente, deduplicación. |
| `consulta_a_criterios/2` | `+Consulta, -ListaCriterios` | 3 | Tokeniza y normaliza sinónimos dentro de Prolog. |
| `estado_consulta/4` | `+Consulta, +Criterios, +Resultados, -Estado` | 3 | Estado único mediante cortes y fallback. |
| `buscar_json/3` | `+Consulta, +Edad, -Json` | 3 | Punto de entrada desde Python; entrega un JSON con resultados. |
| `buscar_json/2` | `+Consulta, -Json` | 3 | Alias sin edad específica (valor `-1`). |

## Priorización de coincidencia en Prolog

| Fuente | Puntaje | Nivel |
|---|---:|---|
| Aptitud infantil verificada | 100 | Alta |
| Género editorial | 95 | Alta |
| Etiqueta editorial | 85 | Alta |
| Tema de sinopsis indexada | 70 | Media |
| Percepción repetida en opiniones | 55 | Media |
| Fuente no prevista (fallback) | 20 | Baja |

## Consultas demostrativas en SWI-Prolog

```prolog
?- buscar_peliculas([terror], -1, Resultados).
?- buscar_peliculas([infantil], 7, Resultados).
?- buscar_peliculas([divertida], -1, Resultados).
?- percepcion_recurrente(el_conjuro, divertida, Total).
?- apta_para_ninos(toy_story).
?- apta_para_ninos(el_conjuro).
?- consulta_a_criterios("películas para niños", Criterios).
?- buscar_json("películas para niños", 7, Json).
```

**Desde Python:** `MotorCine.buscar("películas para niños", edad=7)` ejecuta el predicado `buscar_json/3`. Python **no** calcula compatibilidad etaria, criterios, sentimientos, exclusiones, fuentes ni prioridades.
