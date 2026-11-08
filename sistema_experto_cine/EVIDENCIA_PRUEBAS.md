

```text
[OK]    inferencia definitiva + traza
[OK]    empate + pregunta de desempate
[OK]    negación y condición excluyente
[OK]    filtro etario
[OK]    cobertura de varios criterios
[OK]    consulta vacía
[OK]    criterio desconocido
[OK]    sinónimos y deduplicación
[OK]    búsqueda directa por título
[OK]    consulta películas para niños
[OK]    entrada tratada como dato
[OK]    validación de edad en el puente
[OK]    persistencia y ranking por reseña
[OK]    reseñas recurrentes activan inferencia
[OK]    una reseña y búsqueda por palabras
[OK]    categoría y percepción personalizadas en JSON
[OK]    índice según evidencia
[OK]    filtro infantil combinado
[OK]    migración y recarga JSON
[OK]    DCG: tokenización y criterios en lenguaje natural
[OK]    DCG: búsqueda completa por oración libre
[OK]    DCG: títulos compuestos en lenguaje natural
[OK]    DCG: tolerancia a ruido y nexos en español
[OK]    Modo Experto: inyección, persistencia .pl y reinicio
[OK]    Modo Experto: regla lógica en caliente y lista blanca
[OK]    Pre-procesamiento numérico: discretización continua a discreta

RESULTADO: 26/26 pruebas aprobadas
```

## Cobertura de Entregable 3

| Caso | Entrada principal | Verificación |
|---|---|---|
| **DCG: tokenización y criterios** | `quiero ver una pelicula de terror muy divertida para ninos` | El parser extrae tokens normalizados y mapea a `[divertida, infantil, terror]` sin requerir casillas fijas. |
| **DCG: búsqueda completa** | `una aventura animada con humor familiar` | `modo_dcg: true` activo, extrae `animacion`, `aventura`, `divertida`, `familiar` y devuelve ranking. |
| **DCG: títulos compuestos** | `hotel transilvania para ninos` | Reconoce secuencia multi-palabra `[hotel, transilvania]` mapeándola a `titulo_hotel_transilvania`. |
| **DCG: tolerancia a ruido** | `por favor me gustaria ver algo dramatico con mucho amor` | Ignora palabras no gramaticales y extrae `[drama, romance]`. |
| **Modo Experto: persistencia y reinicio** | Película `interstellar` inyectada en caliente | Comprobación física de escritura al archivo `.pl` y validación de inferencia en un proceso de Python completamente nuevo (simulación de reinicio). |
| **Modo Experto: reglas y seguridad** | Cláusula `ochentera(P) :- pelicula(P,_,A), A<1990` | Inyección dinámica mediante `dynamic/1` + `assertz/1`, listado activo, descarte seguro de predicados del sistema y retracción. |
| **Modo Experto: reglas activas en búsqueda y DCG** | Consultas `vintage`, `un poeta`, `colombiana` | Evaluación en caliente de reglas (`regla_experto_definida/2`), coincidencia dinámica (`r_exp`, 110 pts) y reconocimiento por DCG en lenguaje natural. |
| **Pre-procesamiento numérico** | Edad 8, temperatura 25°C | `discretizar()` genera `['infantil', 'aventura']` y metadatos discretos para Prolog. |

## Reproducción

```powershell
cd sistema_experto_cine
python -m pip install -r requirements.txt
python pruebas.py
```

El proceso retorna código `0` cuando todas las pruebas pasan y `1` si alguna falla.
