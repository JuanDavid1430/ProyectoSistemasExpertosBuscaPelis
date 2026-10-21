"""Puente seguro PySwip -> SWI-Prolog para CineExperto.

Este módulo transporta entradas y salidas. No contiene reglas de selección,
puntajes, trazabilidad ni desempate: toda esa inferencia vive en Prolog.
"""

from __future__ import annotations

import json
from pathlib import Path
from threading import RLock
from typing import Any

try:
    from pyswip import Prolog
except (ImportError, OSError) as exc:  # Mensaje útil al iniciar la interfaz.
    raise RuntimeError(
        "No fue posible cargar PySwip. Instala SWI-Prolog y ejecuta "
        "'python -m pip install -r requirements.txt'."
    ) from exc


class MotorCine:
    """Carga una base Prolog y expone su contrato JSON auditable."""

    MAX_CONSULTA = 240

    def __init__(
        self,
        ruta_base: str | Path | None = None,
        ruta_datos: str | Path | None = None,
    ) -> None:
        self.ruta_base = (
            Path(ruta_base)
            if ruta_base
            else Path(__file__).with_name("base_conocimiento.pl")
        )
        if not self.ruta_base.is_file():
            raise FileNotFoundError(f"No se encontró la base: {self.ruta_base}")

        self.ruta_datos = (
            Path(ruta_datos)
            if ruta_datos
            else Path(__file__).with_name("data") / "resenas_usuario.db"
        )
        self.ruta_datos.parent.mkdir(parents=True, exist_ok=True)
        self._lock = RLock()
        self._cerrado = False
        self.prolog = Prolog()
        self.prolog.consult(str(self.ruta_base.resolve()))
        ruta_datos_prolog = json.dumps(
            str(self.ruta_datos.resolve()), ensure_ascii=False
        )
        if not list(
            self.prolog.query(
                f"inicializar_resenas({ruta_datos_prolog})", maxresult=1
            )
        ):
            raise RuntimeError("No fue posible inicializar el almacén de reseñas.")

    @classmethod
    def _limpiar_consulta(cls, consulta: str) -> str:
        """Valida el tipo y elimina control accidental; no interpreta criterios."""
        if not isinstance(consulta, str):
            raise TypeError("La búsqueda debe ser texto.")
        limpia = " ".join(consulta.replace("\x00", " ").split())
        if len(limpia) > cls.MAX_CONSULTA:
            raise ValueError(
                f"La consulta no puede superar {cls.MAX_CONSULTA} caracteres."
            )
        return limpia

    def buscar(self, consulta: str, edad: int | None = None) -> dict[str, Any]:
        """Invoca ``buscar_json/3`` con argumentos instanciados y seguros."""
        consulta_limpia = self._limpiar_consulta(consulta)
        if edad is not None and (type(edad) is not int or edad < 0 or edad > 120):
            raise ValueError("La edad debe ser un entero entre 0 y 120, o None.")

        edad_prolog = -1 if edad is None else edad
        # json.dumps produce una cadena Prolog entre comillas e impide que la
        # entrada se inyecte como estructura, variable u objetivo ejecutable.
        texto_prolog = json.dumps(consulta_limpia, ensure_ascii=False)
        objetivo = f"buscar_json({texto_prolog}, {edad_prolog}, Json)"
        return self._consultar_json(objetivo)

    def _consultar_json(self, objetivo: str) -> dict[str, Any]:
        """Ejecuta de forma serializada un predicado cuyo último argumento es JSON."""
        with self._lock:
            soluciones = list(self.prolog.query(objetivo, maxresult=1))
        if not soluciones:
            raise RuntimeError("El motor Prolog no devolvió una respuesta.")

        respuesta = json.loads(str(soluciones[0]["Json"]))
        if not isinstance(respuesta, dict):
            raise RuntimeError("El contrato de respuesta del motor no es válido.")
        return respuesta

    def detalle(self, pelicula_id: str) -> dict[str, Any]:
        """Obtiene ficha, metadatos y reseñas directamente desde Prolog."""
        if not isinstance(pelicula_id, str) or not pelicula_id.strip():
            raise ValueError("El identificador de película no es válido.")
        identificador = json.dumps(pelicula_id.strip(), ensure_ascii=False)
        return self._consultar_json(f"detalle_pelicula_json({identificador}, Json)")

    def listar_resenas(self, pelicula_id: str) -> dict[str, Any]:
        """Lista opiniones iniciales y reseñas persistentes de usuarios."""
        if not isinstance(pelicula_id, str) or not pelicula_id.strip():
            raise ValueError("El identificador de película no es válido.")
        identificador = json.dumps(pelicula_id.strip(), ensure_ascii=False)
        return self._consultar_json(f"listar_resenas_json({identificador}, Json)")

    def agregar_resena(
        self,
        pelicula_id: str,
        autor: str,
        texto: str,
        percepcion: str,
        calificacion: int,
    ) -> dict[str, Any]:
        """Valida la captura y delega persistencia e impacto lógico a Prolog."""
        pelicula_id = pelicula_id.strip() if isinstance(pelicula_id, str) else ""
        autor = " ".join(autor.split()) if isinstance(autor, str) else ""
        texto = " ".join(texto.split()) if isinstance(texto, str) else ""
        percepcion = percepcion.strip() if isinstance(percepcion, str) else ""
        if not pelicula_id:
            raise ValueError("Selecciona una película válida.")
        if not 2 <= len(autor) <= 60:
            raise ValueError("El nombre debe tener entre 2 y 60 caracteres.")
        if not 10 <= len(texto) <= 600:
            raise ValueError("La reseña debe tener entre 10 y 600 caracteres.")
        if type(calificacion) is not int or not 1 <= calificacion <= 5:
            raise ValueError("La calificación debe estar entre 1 y 5.")

        argumentos = [pelicula_id, autor, texto, percepcion]
        pelicula_pl, autor_pl, texto_pl, percepcion_pl = (
            json.dumps(valor, ensure_ascii=False) for valor in argumentos
        )
        objetivo = (
            f"agregar_resena_json({pelicula_pl}, {autor_pl}, {texto_pl}, "
            f"{percepcion_pl}, {calificacion}, Json)"
        )
        return self._consultar_json(objetivo)

    def comprobar_conexion(self) -> bool:
        """Prueba mínima de lectura, sin duplicar conocimiento del dominio."""
        with self._lock:
            return bool(list(self.prolog.query("pelicula_valida(_) ", maxresult=1)))

    def cerrar(self) -> None:
        """Sincroniza y libera el archivo persistente (útil en pruebas)."""
        with self._lock:
            if not self._cerrado:
                list(self.prolog.query("db_detach", maxresult=1))
                self._cerrado = True

    def __enter__(self) -> "MotorCine":
        return self

    def __exit__(self, *_: object) -> None:
        self.cerrar()


def mostrar_resultado(datos: dict[str, Any]) -> str:
    """Representación textual para pruebas y entornos sin Streamlit."""
    decision = datos.get("decision", {})
    lineas = [
        f"Consulta: {datos.get('consulta', '')}",
        f"Criterios: {', '.join(datos.get('criterios', [])) or '(ninguno)'}",
        f"Estado: {datos.get('estado')} | Total: {datos.get('total', 0)}",
        f"Decisión: {decision.get('estado', 'sin_datos')}",
    ]
    for numero, pelicula in enumerate(datos.get("resultados", []), 1):
        lineas.append(
            f"\n{numero}. {pelicula['titulo']} ({pelicula['anio']}) | "
            f"Géneros: {', '.join(pelicula['generos'])} | "
            f"Edad: {pelicula['edad_minima']}+ | "
            f"Coincidencia: {pelicula['nivel_coincidencia']} "
            f"({pelicula['puntaje_total']} puntos)"
        )
        lineas.append(f"   {pelicula['justificacion_principal']}")
    recomendacion = decision.get("recomendacion", {})
    if recomendacion.get("pregunta"):
        lineas.append(f"\n¿Qué falta?: {recomendacion['pregunta']}")
    return "\n".join(lineas)
