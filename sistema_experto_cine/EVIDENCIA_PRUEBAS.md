# Plan de pruebas y evidencia — CineExperto

> **Estado de esta entrega:** Este archivo contiene **resultados esperados y verificables**, NO una captura de ejecución real. Para registrar resultados obtenidos se debe correr `python pruebas.py` en una máquina con SWI-Prolog y PySwip instalados y adjuntar `evidencia_terminal.txt` o capturas de la terminal.

| Caso | Objetivo / entrada | Consulta Prolog | Resultado esperado |
|---|---|---|---|
| 1. Normal 1 | Único diagnóstico claro; `películas de romance` | `buscar_json("películas de romance", -1, Json)` | Solo *Titanic* por su género romance. |
| 2. Normal 2 | Múltiples coincidencias; `películas divertidas` | `buscar_json("películas divertidas", -1, Json)` | *El Conjuro* aparece por opiniones, mantiene género terror; también *Shrek*. |
| 3. Exclusión | Niños de 7 años; `películas para niños` | `buscar_json("películas para niños", 7, Json)` | *Toy Story*, *Coco*, *Shrek* sí; *El Conjuro*, *Deadpool*, *Coraline* y el registro sintético `caso_terror_infantil` no. |
| 4. Borde 1 | Restricción edad 5; `películas divertidas` | `buscar_json("películas divertidas", 5, Json)` | *Shrek* sí; *El Conjuro* y *Deadpool* no. |
| 5. Borde 2 | Consulta vacía `""` | `buscar_json("", -1, Json)` | Estado `consulta_vacia`, lista `[]`. |
| 6. Adicional | Texto sin vocabulario reconocido | `buscar_json("películas intergalácticas", -1, Json)` | `criterio_no_reconocido`, lista `[]`. |
| 7. Adicional | Redundancia `divertidas graciosas divertidas` | `buscar_json("divertidas graciosas divertidas", -1, Json)` | `criterios=[divertida]`; películas únicas. |
| 8. Adicional | Búsqueda de género `películas de terror` | `buscar_json("películas de terror", -1, Json)` | *El Conjuro* e *It*, no *Toy Story*. |

## Evidencia reproducible

```bash
python pruebas.py > evidencia_terminal.txt
```

El script imprime para **cada caso** objetivo, entrada, consulta Prolog, expectativa, datos obtenidos y `APROBADO`/`FALLÓ`, seguido de total de pruebas. El código retorna `0` cuando todas pasan y `1` si al menos una falla.

## Revisión manual de los requisitos

- Hechos con aridad >= 2: ocho predicados y más de treinta registros.
- Reglas de encadenamiento: R01–R29, tres niveles, llamadas cruzadas explícitas.
- Listas: `findall/3`, `sort/2`, `length/2`, `member/2` y recorrido con acumulador.
- Corte `!`: `edad_habilitada/2`, `puntaje_fuente/2`, `prioridad_de_puntaje/2`, `estado_consulta/4`.
- Negación por fallo `\+`: `apta_para_ninos/1`, con película instanciada.
- Múltiples hipótesis: cinco fuentes de coincidencia y todas las evidencias por película.
- Prioridad: escala de 20 a 100 calculada exclusivamente en Prolog.
- Caso de lista vacía: `findall` y `sort` retornan una lista vacía sin excepción.

**Importante:** comprobar la ejecución real antes de presentar este reporte como validación definitiva, porque aquí no se dispuso del intérprete SWI-Prolog.
