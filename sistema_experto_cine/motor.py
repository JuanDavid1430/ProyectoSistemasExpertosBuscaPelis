"""Puente PySwip -> SWI-Prolog. Toda la inferencia permanece en Prolog."""
import json
from pathlib import Path
from typing import Any

try:
    from pyswip import Prolog
except (ImportError, OSError) as exc:
    raise RuntimeError(
        "Instale SWI-Prolog y el puente con: pip install -r requirements.txt"
    ) from exc


class MotorCine:
    def __init__(self, ruta_base: str | Path | None = None) -> None:
        self.ruta_base = (Path(ruta_base) if ruta_base else
                          Path(__file__).with_name("base_conocimiento.pl"))
        if not self.ruta_base.is_file():
            raise FileNotFoundError(f"No se encontró {self.ruta_base}")
        self.prolog = Prolog()
        self.prolog.consult(str(self.ruta_base.resolve()))

    def buscar(self, consulta: str, edad: int | None = None) -> dict[str, Any]:
        """Consulta a Prolog; edad=None significa sin restricción etaria."""
        if not isinstance(consulta, str):
            raise TypeError("La búsqueda debe ser texto.")
        if edad is not None and (type(edad) is not int or edad < 0):
            raise ValueError("La edad debe ser un entero >= 0 o None.")
        edad_pl = -1 if edad is None else edad
        # json.dumps genera una cadena entre comillas dobles, también válida
        # como string Prolog. Se evita interpretar entrada como código Prolog.
        consulta_pl = json.dumps(consulta, ensure_ascii=False)
        objetivo = f"buscar_json({consulta_pl}, {edad_pl}, Json)"
        soluciones = list(self.prolog.query(objetivo, maxresult=1))
        if not soluciones:
            raise RuntimeError("No hubo respuesta del motor Prolog.")
        return json.loads(str(soluciones[0]["Json"]))


def mostrar_resultado(d: dict[str, Any]) -> str:
    """Presentación exclusivamente visual; no puntúa ni filtra."""
    lineas = [
        f"Consulta: {d['consulta']}",
        f"Criterios: {', '.join(d['criterios']) or '(ninguno)'}",
        f"Estado: {d['estado']} | Total: {d['total']}",
    ]
    for n, p in enumerate(d["resultados"], 1):
        lineas.append(
            f"\n{n}. {p['titulo']} ({p['anio']}) | "
            f"Géneros: {', '.join(p['generos'])} | Edad: {p['edad_minima']}+ | "
            f"Relevancia: {p['prioridad']} ({p['puntaje']})"
        )
        lineas.append(f"   Explicación [{p['origen_principal']}]: {p['justificacion_principal']}")
        for e in p["evidencias"]:
            lineas.append(f"   - {e['criterio']} [{e['origen']}]: {e['justificacion']}")
    return "\n".join(lineas)
