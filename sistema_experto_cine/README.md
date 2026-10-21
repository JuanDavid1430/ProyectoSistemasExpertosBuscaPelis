# CineExperto — buscador explicable de películas

Proyecto académico de **Sistemas Expertos**. CineExperto conecta una interfaz
web en Streamlit con un motor simbólico en SWI-Prolog mediante PySwip. Además de
recomendar películas, expone las reglas disparadas, los hechos comprobados, las
hipótesis descartadas y la pregunta que falta cuando la evidencia no permite
elegir una única opción.

Repositorio: <https://github.com/JuanDavid1430/ProyectoSistemasExpertosBuscaPelis>

## Arquitectura híbrida

```text
Usuario → Streamlit (captura y presentación)
        → MotorCine / PySwip (transporte seguro)
        → base_conocimiento.pl (inferencia, ranking, traza y desempate)
        → JSON auditable → Streamlit
```

- `main.py` no puntúa ni descarta películas: únicamente presenta la respuesta.
- `motor.py` valida tipos, instancia los argumentos y transporta un JSON.
- `base_conocimiento.pl` contiene hechos, reglas, negación, cortes, ranking,
  auditoría, recomendación de evidencia adicional y reseñas persistentes.
- No se utiliza `read/1`; por eso Prolog nunca bloquea el hilo de la interfaz.

## Cartelera, fichas y reseñas

- Cada resultado aparece como una tarjeta vertical tipo cartelera.
- El buscador reconoce preferencias temáticas, expresiones como
  `películas para niños` y los títulos del catálogo, por ejemplo `Toy Story`.
- El botón **Ver película** abre una vista con póster, sinopsis,
  metadatos, explicación de la coincidencia y comentarios.
- Los pósters se colocan en `assets/posters` siguiendo los nombres indicados en
  `assets/posters/README.md`. Mientras se suministran, aparece una cubierta de
  reserva legible.
- Las reseñas nuevas se guardan en `data/resenas_usuario.db` mediante la
  biblioteca de persistencia de SWI-Prolog.
- Una calificación sirve como desempate inmediato entre resultados con la misma
  evidencia simbólica. Dos autores distintos con la misma percepción activan
  una evidencia por opiniones en búsquedas posteriores.

## Requisitos

- Python 3.10 o posterior, de 64 bits.
- SWI-Prolog de 64 bits instalado y disponible en `PATH`.
- PySwip y Streamlit, declarados en `requirements.txt`.

En Windows, Python y SWI-Prolog deben usar la misma arquitectura. Si PySwip no
encuentra la biblioteca nativa, agrega las carpetas `bin` de SWI-Prolog al
`PATH`, cierra la terminal y vuelve a abrirla.

## Instalación y ejecución

```powershell
cd sistema_experto_cine
python -m pip install -r requirements.txt
streamlit run main.py
```

También se admite `python main.py`. El archivo detecta que fue iniciado fuera
de Streamlit y se relanza automáticamente con el mismo intérprete de Python.

La aplicación se abre normalmente en <http://localhost:8501>. Para detenerla,
presiona `Ctrl+C` en la terminal.

## Casos requeridos para la demostración

### Caso 1 — inferencia completa y «¿Por qué?»

1. Consulta: `películas de romance`.
2. Edad: sin filtro.
3. Resultado esperado: **Titanic** como hipótesis única.
4. Abre la pestaña **¿Por qué?** y muestra reglas, hechos verdaderos y descartes.

### Caso 2 — evidencia incompleta y «¿Qué falta?»

1. Consulta: `películas divertidas`.
2. Edad: sin filtro.
3. Resultado esperado: varias hipótesis líderes con el mismo puntaje.
4. Abre **¿Qué falta?**. Prolog sugiere una preferencia adicional que divide a
   las candidatas, por ejemplo si debe ser apta para público infantil.

## Pruebas

```powershell
python pruebas.py
```

Las **12 pruebas** cubren el puente PySwip, una decisión definitiva, un empate,
la traza, el filtro etario, la exclusión con `\+`, entradas seguras, persistencia
de reseñas, actualización del ranking y activación de inferencias por opiniones.

## Archivos de entrega

- `main.py`: interfaz moderna en Streamlit.
- `motor.py`: puente seguro con PySwip.
- `base_conocimiento.pl`: motor simbólico y de explicabilidad.
- `DICCIONARIO_PREDICADOS.md`: modos `+`, `-`, `?` y documentación técnica.
- `pruebas.py`: validación automatizada de los dos flujos del entregable.
- `GUIA_VIDEO.md`: guion sugerido para la demostración de 3 a 5 minutos.
- `assets/posters/README.md`: nombres esperados para los pósters suministrados.
- `data/resenas_usuario.db`: almacenamiento generado en ejecución (ignorado por Git).
- `../INFORME_ENTREGA_2.md`: informe listo para anexar a la Entrega 1.

## Alcance y advertencia

El catálogo es local y usa vocabulario controlado. Las edades, etiquetas y
opiniones son datos didácticos, no clasificaciones oficiales ni recomendaciones
de seguridad. El registro `caso_terror_infantil` es sintético y existe para
demostrar una hipótesis descartada por condición excluyente.
