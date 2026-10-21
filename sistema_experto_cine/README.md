# CineExperto — Sistema experto de búsqueda explicable de películas

Entregable 1 para **Sistemas Expertos**. Un buscador global de películas que explica por qué aparecen en resultados, basado en hechos y reglas con **SWI-Prolog** y puente **PySwip + Python**. La fase actual es exclusivamente de **consola**; el dashboard queda para una etapa posterior.

## Ejemplos de razonamiento

- **«Películas de terror»**: devuelve películas con el género editorial de terror, como *El Conjuro*.
- **«Películas divertidas»**: combina etiquetas, temas indexados de sinopsis y opiniones recurrentes. *El Conjuro* puede coincidir por dos reseñas que la describen como divertida; **sigue clasificada como terror**.
- **«Películas para niños»**: exige edad mínima ilustrativa <= 10, etiquetas infantiles/familiares y exclusión de género terror. Si se añade `edad=7`, no muestra películas cuyo mínimo sea superior a 7.
- **Consulta vacía o desconocida**: retorna lista vacía con estado explicativo, sin error.

**Precaución:** el catálogo utiliza 15 películas reales y 1 registro sintético de prueba (`caso_terror_infantil`), clasificaciones etarias de demostración y reseñas ficticias. No son ratings oficiales ni recomendaciones de seguridad para un niño real.

## Requisitos

- Python 3.10+.
- SWI-Prolog instalado y accesible desde el sistema (incluida su biblioteca nativa).
- PySwip, instalado con `pip install -r requirements.txt`.

En **Ubuntu/Debian** se puede instalar SWI-Prolog mediante los paquetes oficiales de la distribución; por ejemplo: `sudo apt update && sudo apt install swi-prolog-nox`. En **Windows**, instalar SWI-Prolog de su página oficial y agregarlo al `PATH` junto con la biblioteca nativa; Python y SWI-Prolog deben utilizar arquitecturas compatibles. Si PySwip no detecta la librería, revisar la configuración de `SWI_HOME_DIR`/`PATH` según la plataforma.

## Ejecución

```bash
cd sistema_experto_cine
python -m pip install -r requirements.txt
python main.py
```

Para correr el conjunto de ocho casos y **generar evidencia real**:

```bash
python pruebas.py
python pruebas.py > evidencia_terminal.txt
```

## Archivos

- `FICHA_PROYECTO.md`: problema, justificación, alcance, participantes y casos de uso.
- `base_conocimiento.pl`: 163 hechos estructurados (conteo en la muestra), 29 reglas enumeradas R01–R29 en tres niveles, listas, corte, negación, recolección, deduplicación y ranking.
- `motor.py`: puente que carga Prolog, consulta `buscar_json/3` y muestra resultados.
- `main.py`: ciclo de búsqueda en la terminal.
- `pruebas.py`: ocho pruebas automáticas con comparación de esperado y obtenido.
- `DICCIONARIO_PREDICADOS.md`: firmas, aridad, modos y responsabilidades.
- `EVIDENCIA_PRUEBAS.md`: matriz de resultados **esperados** y modo de reproducir la ejecución.

## Reglas de diseño

1. Los hechos de género, etiquetas y edad provienen de una fuente editorial. Las opiniones nunca actualizan esas categorías.
2. Para considerar un comentario relevante se necesitan **al menos dos autores distintos** con la misma percepción. No es un clasificador automático de texto: el campo de percepción está estructurado en los hechos.
3. Las búsquedas de `terror` se restringen al **género editorial**, evitando que comentarios aislados o temas indexados lo sustituyan.
4. La sinopsis se consulta por su índice `tema_sinopsis/2`, curado manualmente; no se afirma tener búsquedas semánticas con embeddings o IA generativa.
5. Se conservan **todas** las evidencias por película; un orden de prioridad escoge el motivo principal y ordena la búsqueda.
6. Prolog implementa todos los filtros y decisiones; Python solo transporta datos y los imprime.

## Limitaciones de la primera entrega

Las búsquedas utilizan un vocabulario controlado de sinónimos. Las palabras desconocidas se ignoran si alguna palabra conocida está presente; si no hay ninguna, aparece `criterio_no_reconocido`. Cuando hay varios criterios reconocidos en una consulta se combinan con lógica **OR** (basta una coincidencia), se deduplican películas y se conserva el detalle de cada motivo. El filtro de edad se combina con **AND** y es siempre restrictivo. El objetivo siguiente es incorporar un API, fuentes contrastadas y dashboard.
