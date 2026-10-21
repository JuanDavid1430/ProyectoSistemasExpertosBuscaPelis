# Estado de verificación del paquete

- Verificación estática de Python: **satisfactoria** usando `python -m py_compile` sobre `main.py`, `motor.py` y `pruebas.py`.
- Conteo de hechos: **163**, todos con aridad mayor o igual a 2, agrupados por predicado.
- Reglas enumeradas: **29** (`R01` a `R29`), incluyendo nivel preliminar, inferencia intermedia y conclusión.
- Motor SWI-Prolog: **no instalado en el entorno donde se preparó este paquete**. Por tanto, todavía **no se ejecutaron** consultas Prolog ni pruebas de integración PySwip. No se adjuntan resultados obtenidos ficticios.
- Para terminar la validación y documentar evidencia real: instalar SWI-Prolog y PySwip, ejecutar `python pruebas.py > evidencia_terminal.txt` y adjuntar el registro a la entrega.
- Integrantes y códigos: deben completarse en `FICHA_PROYECTO.md` antes de presentar.
