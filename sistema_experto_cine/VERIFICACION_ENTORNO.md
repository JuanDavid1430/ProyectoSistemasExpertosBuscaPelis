# Verificación del entorno — Entregable 2

- Fecha de verificación: **20 de octubre de 2026**.
- Python: **3.14.3** en el equipo de desarrollo (el proyecto admite 3.10+).
- SWI-Prolog: **10.0.2 x64**.
- PySwip: carga y consulta correctas mediante `buscar_json/3`.
- Sintaxis Python: `main.py`, `motor.py` y `pruebas.py` compilan correctamente.
- Sintaxis Prolog: `base_conocimiento.pl` carga sin errores.
- Integración: **12/12 pruebas aprobadas**, incluidas persistencia y actualización inferencial por reseñas.
- Interfaz: Streamlit incluida en `requirements.txt`; inicio esperado con
  `streamlit run main.py`.

La base no utiliza `read/1`. La consulta se envía como cadena instanciada y el
motor retorna un único JSON con resultados, decisión y auditoría.
