# Ficha de definición del proyecto — Entregable 1

**Asignatura:** Sistemas Expertos  
**Título tentativo:** **CineExperto: sistema experto para búsqueda explicable y recomendación de películas**  
**Modalidad:** Trabajo en pareja, máximo dos integrantes  
**Fecha:** 13 de octubre de 2026  
**Estado:** Propuesta y prototipo de motor lógico en consola

## 1. Integrantes

| Rol | Nombre completo | Código estudiantil | Correo institucional |
|---|---|---|---|
| Integrante 1 | [Completar] | [Completar] | [Completar] |
| Integrante 2 | [Completar] | [Completar] | [Completar] |

## 2. Problema que aborda

Las carteleras y buscadores tradicionales suelen depender de categorías fijas como «terror», «comedia» o «animación», por lo que no explican por qué una película puede aparecer ante una búsqueda subjetiva como «películas divertidas». Los comentarios pueden describir una película de una forma distinta a su género registrado. Además, una recomendación para menores debe respetar restricciones de edad y criterios editoriales, aunque una reseña diga que la película fue divertida.

**Ejemplo central:** *El Conjuro* tiene el género de terror en los hechos del prototipo, pero dos revisores ficticios la describieron como divertida. Al buscar «películas divertidas», puede aparecer por **coincidencia con opiniones**; en su ficha seguirá identificada como terror. En cambio, «películas para niños» no debe mostrarla por su clasificación etaria y falta de orientación infantil.

## 3. Objetivo general

Implementar un sistema experto de búsqueda de películas que aplique reglas lógicas en Prolog para integrar géneros, etiquetas, clasificación de edad, temas de sinopsis y opiniones de revisores, con explicaciones trazables del motivo de cada coincidencia y comunicación con Python a través de una aplicación de consola.

## 4. Objetivos específicos

1. Representar mediante hechos estructurados un catálogo de películas con atributos y reseñas.
2. Implementar inferencias multinivel, negación por fallo, cortes, tratamiento de listas y recolección de resultados únicos.
3. Clasificar la prioridad de cada coincidencia según la confiabilidad de la fuente.
4. Separar la lógica de decisiones en Prolog de la entrada/salida en Python.
5. Demostrar el funcionamiento con un conjunto de pruebas reproducibles por consola.

## 5. Casos de uso principales

| Caso | Búsqueda / entrada | Inferencia esperada | Comportamiento esencial |
|---|---|---|---|
| CU-01 | «Películas de terror» | Género editorial `terror` | Retorna *El Conjuro*, *It* y *Annabelle*. |
| CU-02 | «Películas divertidas» | Coincidencia por etiquetas, temas de sinopsis y reseñas recurrentes | Puede aparecer *El Conjuro* **por opiniones** sin cambiar su género. |
| CU-03 | «Películas para niños» | Etiqueta `infantil`/`familiar`, edad mínima <= 10, ausencia de género terror | Retorna películas infantiles/familiares; excluye las adultas. |
| CU-04 | «Películas para niños», edad 7 | CU-03 + compatibilidad con edad del espectador | Incluye *Coco* (7+) y excluye *Coraline* (10+) en los datos de prueba. |
| CU-05 | «Películas divertidas», edad 5 | Coincidencia semántica + filtro de edad | Puede mostrar *Shrek* y evita *El Conjuro* o *Deadpool*. |
| CU-06 | Entrada vacía o desconocida | Reglas de fallback | Lista vacía y estado explicativo; no genera excepción. |

## 6. Alcance delimitado

**Incluido en Entregable 1:** catálogo local de 16 registros (15 películas y un caso sintético de exclusión); géneros y etiquetas editoriales; edad mínima; sinopsis e índice temático manual; opiniones ficticias con autor y percepción; sinónimos controlados; inferencias de coincidencia; explicaciones por fuente; ranking; búsqueda en consola; integración PySwip; pruebas automatizadas.

**No incluido todavía:** dashboard gráfico, frontend web, autenticación, conexión con API externa de cartelera, disponibilidad real de funciones/horarios, persistencia en base de datos, carga automática de reseñas, reconocimiento libre del lenguaje natural mediante IA ni aprendizaje automático. Se plantea el **dashboard** como una fase posterior que consumirá el mismo motor mediante una API.

## 7. Entradas y salidas

- **Entradas:** frase textual de búsqueda y, opcionalmente, edad del espectador (entero no negativo).
- **Salidas:** estado de la consulta, criterios interpretados, películas sin duplicados, título, año, género real en los hechos, edad mínima, sinopsis, prioridad, puntaje, fuente principal y explicación de cada evidencia.
- **Diagnósticos/resultados esperados:** coincidencia por género; coincidencia por etiqueta; coincidencia por tema de sinopsis; coincidencia por opinión recurrente; recomendación infantil validada; exclusión por edad/terror; consulta sin criterios; sin resultados.

## 8. Por qué corresponde a un sistema experto

La solución se apoya en conocimiento declarativo y reglas **explicables**, no en una consulta `LIKE` o en la clasificación de un modelo predictivo. Las conclusiones derivan de varias etapas: se valida el hecho, se infiere una condición intermedia (por ejemplo, opinión recurrente o aptitud infantil) y finalmente se decide si una película coincide y cuál es la prioridad de la coincidencia. El resultado muestra **cómo se obtuvo**, conservando separados hechos editoriales y percepciones subjetivas.

## 9. Política de interpretación y ética de datos

- Las edades y etiquetas incluidas en este prototipo son **ejemplos académicos** y no representan clasificaciones oficiales de ningún país. En producción deberán provenir de una fuente autorizada y una jurisdicción definida.
- Las opiniones del archivo son **ficticias**, únicamente para demostrar reglas.
- Un registro intencionalmente contradictorio, *Caso de prueba: terror infantil*, combina etiqueta infantil, edad 7 y género terror para verificar que `\+` efectivamente lo excluya. No corresponde a una película comercial.
- La palabra «divertida» en dos reseñas no cambia el género oficial de una película.
- La aptitud para niños se determina por clasificación etaria y etiquetas, nunca por una opinión; se descarta contenido de género terror.
- Para búsquedas subjetivas se exige como mínimo **dos autores distintos** que registren la misma percepción, si la evidencia viene de comentarios.
- La búsqueda de sinopsis utiliza **conceptos manualmente indexados**, no análisis libre de lenguaje ni minería automática de sentimientos.

## 10. Evolución propuesta del proyecto

**Fase 1 (esta entrega):** motor lógico Prolog + Python en consola.  
**Fase 2:** ampliar y validar el conocimiento con fuentes verificables y más escenarios, evaluación de relevancia.  
**Fase 3:** API Python y dashboard de cartelera con buscador global, filtros visibles por edad/género y sección «¿Por qué apareció esta película?».
