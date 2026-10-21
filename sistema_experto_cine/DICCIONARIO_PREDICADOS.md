# Diccionario de predicados de CineExperto

Convención de modos: `+` entrada instanciada, `-` salida y `?` argumento que
puede usarse como entrada o salida. La interfaz invoca únicamente
`buscar_json/3`; los demás predicados pertenecen al motor simbólico.

## Hechos y conocimiento declarativo

| Predicado/aridad | Modo | Descripción |
|---|---|---|
| `pelicula/3` | `?Id, ?Titulo, ?Anio` | Catálogo y metadatos principales. |
| `genero/2` | `?Id, ?Genero` | Género editorial de una película. |
| `etiqueta/2` | `?Id, ?Etiqueta` | Etiquetas editoriales del catálogo. |
| `edad_minima/2` | `?Id, ?Edad` | Edad mínima didáctica. |
| `sinopsis/2` | `?Id, ?Texto` | Sinopsis ampliada de la película. |
| `tema_sinopsis/2` | `?Id, ?Tema` | Índice temático manual de la sinopsis. |
| `opinion/4` | `?Id, ?Autor, ?Texto, ?Percepcion` | Opinión ficticia estructurada. |
| `sinonimo/2` | `?Token, ?Criterio` | Normalización del vocabulario de consulta. |
| `titulo_consulta/3` | `?Criterio, ?Id, ?Palabras` | Índice de títulos y alias reconocibles en una consulta. |
| `peso_criterio/2` | `?Criterio, ?Peso` | Prioridad simbólica de una pregunta de desempate. |
| `pregunta_criterio/2` | `?Criterio, ?Pregunta` | Texto sugerido para solicitar evidencia adicional. |

## Validación e inferencia de búsqueda

| Predicado/aridad | Modo | Función |
|---|---|---|
| `pelicula_valida/1` | `?P` | Comprueba pertenencia al catálogo. |
| `genero_validado/2` | `?P, ?G` | Valida el género contra una película existente. |
| `etiqueta_validada/2` | `?P, ?E` | Valida una etiqueta editorial. |
| `tema_validado/2` | `?P, ?T` | Exige película, sinopsis e índice temático. |
| `edad_valida/2` | `?P, ?Min` | Verifica una edad mínima entera no negativa. |
| `edad_compatible/2` | `?P, +Edad` | Prueba que la edad ingresada alcance el mínimo. |
| `edad_habilitada/2` | `+P, +Edad` | Acepta `-1` como ausencia de filtro o aplica compatibilidad. |
| `opinion_validada/3` | `?P, ?Autor, ?Tema` | Unifica opiniones iniciales y reseñas persistentes. |
| `contenido_de_terror/1` | `?P` | Detecta el género que activa una exclusión infantil. |
| `orientacion_infantil/1` | `?P` | Reconoce etiquetas infantil o familiar. |
| `percepcion_recurrente/3` | `?P, +Tema, -Total` | Exige dos autores distintos para usar opiniones como evidencia. |
| `apta_para_ninos/1` | `?P` | Edad ≤ 10, orientación infantil y `\+ contenido_de_terror(P)`. |
| `coincidencia_genero/4` | `?P, +C, -Fuente, -Motivo` | Produce evidencia de género. |
| `coincidencia_etiqueta/4` | `?P, +C, -Fuente, -Motivo` | Produce evidencia de etiqueta. |
| `coincidencia_sinopsis/4` | `?P, +C, -Fuente, -Motivo` | Produce evidencia temática. |
| `coincidencia_opinion/4` | `?P, +C, -Fuente, -Motivo` | Produce evidencia de percepción recurrente. |
| `coincidencia_infantil/4` | `?P, +infantil, -Fuente, -Motivo` | Produce evidencia de aptitud infantil. |
| `coincidencia_titulo/4` | `?P, +C, -Fuente, -Motivo` | Produce evidencia de coincidencia directa con un título. |
| `coincidencia/4` | `?P, +C, -Fuente, -Motivo` | Unifica las seis fuentes posibles. |
| `criterio_admisible/2` | `+P, +C` | Aplica filtros duros para `infantil` y `terror`. |
| `puntaje_fuente/2` | `+Fuente, -Puntos` | Peso: título 120, infantil 100, género 95, etiqueta 85, sinopsis 70, opiniones 55. |
| `prioridad_de_puntaje/2` | `+Puntos, -Nivel` | Clasifica prioridad alta, media o baja. |
| `evidencia/3` | `?P, +C, -Termino` | Empaqueta criterio, fuente, motivo y puntaje. |
| `mejor_evidencia/2` | `+Lista, -Mejor` | Selecciona el elemento de mayor peso. |
| `mejor_aux/3` | `+Resto, +Acumulada, -Mejor` | Recorrido estructural de selección. |
| `mejor_evidencia_criterio/3` | `+P, +C, -Mejor` | Impide puntuar dos veces un mismo criterio. |
| `suma_puntajes/2` | `+Evidencias, -Total` | Suma el mejor aporte por criterio. |
| `nivel_coincidencia/3` | `+Solicitados, +Cobertura, -Nivel` | Deriva `muy_alta`, `alta`, `parcial` o `insuficiente`. |
| `evidencia_dict/2` | `+Termino, -Dict` | Convierte evidencia a estructura exportable. |
| `calificacion_promedio/2` | `+P, -Promedio` | Calcula el promedio de las calificaciones aportadas por usuarios. |
| `resultado_para/3` | `+Criterios, +P, -Dict` | Construye una hipótesis con cobertura, puntaje y valoración. |
| `buscar_peliculas/3` | `+Criterios, +Edad, -Resultados` | Deduplica, filtra y ordena hipótesis. |
| `contiene_secuencia/2` | `+Secuencia, +Palabras` | Comprueba que las palabras de un título aparezcan consecutivamente. |
| `consulta_a_criterios/2` | `+Consulta, -Criterios` | Normaliza el texto exclusivamente en Prolog. |
| `estado_consulta/4` | `+Consulta, +Criterios, +Resultados, -Estado` | Determina el estado funcional de la consulta. |

## Módulo «¿Por qué?» — explicabilidad

| Predicado/aridad | Modo | Función |
|---|---|---|
| `regla_catalogo/3` | `?Id, ?Nombre, ?Detalle` | Metadatos legibles de reglas auditables. |
| `regla_fuente/2` | `?Fuente, ?IdRegla` | Relaciona una fuente de evidencia con reglas disparadas. |
| `regla_dict/2` | `+Id, -Dict` | Serializa una regla. |
| `reglas_disparadas/3` | `+Criterios, +P, -Reglas` | Reconstruye la ruta lógica de la hipótesis principal. |
| `hecho_evidencia/4` | `+P, +C, +Fuente, -Texto` | Materializa el hecho unificado por una evidencia. |
| `hechos_verdaderos/4` | `+Criterios, +Edad, +P, -Hechos` | Reúne hechos del catálogo y entrada comprobados. |
| `motivo_descarte/7` | `+Criterios, +Edad, +Resultados, +Competidores, -P, -Titulo, -Motivo` | Explica exclusión, edad, falta de evidencia o menor puntaje. |
| `primeros_n/3` | `+N, +Lista, -Prefijo` | Limita la lista visual sin alterar la decisión. |
| `hipotesis_descartadas/5` | `+Criterios, +Edad, +Resultados, +Competidores, -Descartadas` | Recolecta alternativas y sus causas. |
| `auditoria_motor/5` | `+Criterios, +Edad, +Resultados, +Competidores, -Auditoria` | Construye reglas, hechos y descartes del panel «¿Por qué?». |

## Módulo «¿Qué falta?» — recomendación

| Predicado/aridad | Modo | Función |
|---|---|---|
| `mejor_puntaje/2` | `+Resultados, -Puntaje` | Obtiene el puntaje líder de la lista ordenada. |
| `hipotesis_competencia/2` | `+Resultados, -Competidores` | Conserva todas las hipótesis empatadas en primer lugar. |
| `competidor_dict/2` | `+Resultado, -Dict` | Resume una hipótesis para la interfaz. |
| `criterio_soportado/2` | `+P, ?C` | Comprueba si una película aporta evidencia admisible. |
| `candidato_desempate/4` | `+Criterios, +Ids, -C, -Score` | Busca un criterio no preguntado que divida a los líderes. |
| `mejor_par/2` | `+Pares, -Mejor` | Selecciona el criterio adicional de mayor prioridad. |
| `recomendacion_desempate/3` | `+Criterios, +Competidores, -Dict` | Formula la mejor pregunta cuando existe empate. |
| `recomendacion_confirmacion/3` | `+Criterios, +Competidor, -Dict` | Pide evidencia para completar una hipótesis parcial. |
| `decision_motor/4` | `+Criterios, +Resultados, +Competidores, -Decision` | Emite decisión definitiva, insuficiente o sin candidatos. |
| `buscar_json/3` | `+Consulta, +Edad, -Json` | Contrato auditable PySwip–Prolog con resultados, decisión y auditoría. |
| `buscar_json/2` | `+Consulta, -Json` | Alias que usa `-1` como ausencia de filtro etario. |

## Cartelera y reseñas persistentes

| Predicado/aridad | Modo | Función |
|---|---|---|
| `resena_usuario/6` | `?P, ?Autor, ?Texto, ?Percepcion, ?Calificacion, ?Fecha` | Hecho persistente generado por `library(persistency)`. |
| `inicializar_resenas/1` | `+Archivo` | Adjunta el almacén local indicado por Python. |
| `normalizar_atom_entrada/2` | `+Entrada, -Atom` | Acepta texto o átomo y produce una clave validable. |
| `texto_limpio/5` | `+Entrada, +Min, +Max, -Texto, -Atom` | Normaliza espacios y valida la longitud de una captura. |
| `percepcion_permitida/1` | `?Percepcion` | Vocabulario admitido para nuevas reseñas. |
| `resena_dict/2` | `+P, -Dict` | Unifica opiniones base y reseñas de la comunidad para la UI. |
| `listar_resenas/2` | `+P, -Resenas` | Reúne todos los comentarios de una película. |
| `listar_resenas_json/2` | `+Id, -Json` | Contrato JSON del panel de comentarios. |
| `detalle_pelicula_json/2` | `+Id, -Json` | Devuelve ficha, sinopsis, etiquetas, valoración y reseñas. |
| `autores_percepcion/3` | `+P, +Percepcion, -Total` | Cuenta autores únicos que respaldan una percepción. |
| `agregar_resena_json/6` | `+Id, +Autor, +Texto, +Percepcion, +Calificacion, -Json` | Valida, persiste y reporta el impacto inferencial de una reseña. |

La calificación promedio se utiliza únicamente como desempate entre hipótesis
con el mismo puntaje simbólico. Las opiniones no alteran géneros ni etiquetas:
una percepción participa como evidencia solo cuando existen dos autores
distintos, manteniendo la regla de recurrencia del sistema experto.

## Consultas demostrativas

```prolog
?- buscar_json("películas de romance", -1, Json).
?- buscar_json("películas divertidas", -1, Json).
?- buscar_json("Toy Story", -1, Json).
?- buscar_json("películas para niños", -1, Json).
?- reglas_disparadas([romance], titanic, Reglas).
?- hipotesis_competencia(Resultados, Competidores).
?- recomendacion_desempate([divertida], Competidores, Recomendacion).
```

Python no calcula criterios, cobertura, puntajes, descartes ni preguntas; solo
valida el tipo de entrada y presenta el JSON producido por `buscar_json/3`.
