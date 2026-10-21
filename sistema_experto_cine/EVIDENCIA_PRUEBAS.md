# Evidencia de pruebas — Entregable 2

Ejecución local realizada el **20 de octubre de 2026** con SWI-Prolog 10.0.2,
PySwip y Python. Resultado obtenido: **12/12 pruebas aprobadas**.

```text
[OK]    inferencia definitiva + traza
[OK]    empate + pregunta de desempate
[OK]    negación y condición excluyente
[OK]    filtro etario
[OK]    cobertura de varios criterios
[OK]    consulta vacía
[OK]    criterio desconocido
[OK]    sinónimos y deduplicación
[OK]    entrada tratada como dato
[OK]    validación de edad en el puente
[OK]    persistencia y ranking por reseña
[OK]    reseñas recurrentes activan inferencia

RESULTADO: 12/12 pruebas aprobadas
```

## Cobertura

| Caso | Entrada principal | Verificación |
|---|---|---|
| Inferencia completa | `películas de romance` | Titanic es líder único; decisión `definitiva`; traza contiene R02 y R13. |
| Evidencia insuficiente | `películas divertidas` | Cuatro líderes empatan; Prolog recomienda preguntar por `infantil`. |
| Condición excluyente | `películas para niños`, edad 7 | El caso sintético de terror se descarta por `\+ contenido_de_terror/1`. |
| Edad | `películas divertidas`, edad 5 | Se excluyen Deadpool, El Conjuro y Hotel Transilvania. |
| Cobertura múltiple | `animación de aventura` | Toy Story y Nemo cubren ambos criterios. |
| Entrada vacía | espacios | Estado `consulta_vacia`, sin excepción. |
| Vocabulario desconocido | `películas intergalácticas` | Estado `criterio_no_reconocido`. |
| Deduplicación | sinónimos repetidos | Un criterio canónico y resultados únicos. |
| Seguridad | texto con comillas y términos | La entrada se trata como dato, no como objetivo Prolog. |
| Validación de puente | edad `-2` | Python rechaza el tipo/rango antes de consultar. |
| Persistencia | nueva reseña de Toy Story | El comentario queda disponible y la valoración desempata el ranking. |
| Inferencia dinámica | dos reseñas `emocionante` para Titanic | La percepción recurrente activa a Titanic en una búsqueda posterior. |

## Reproducción

```powershell
cd sistema_experto_cine
python -m pip install -r requirements.txt
python pruebas.py
```

El proceso retorna código `0` cuando todas las pruebas pasan y `1` si alguna
falla.
