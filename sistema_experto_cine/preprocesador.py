from __future__ import annotations
from dataclasses import dataclass, field
from typing import Any

# ---------------------------------------------------------------------------
# Intentar importar scikit-learn (opcional)
# ---------------------------------------------------------------------------
try:
    from sklearn.preprocessing import KBinsDiscretizer  # type: ignore
    import numpy as np  # type: ignore
    _SKLEARN_DISPONIBLE = True
except ImportError:
    _SKLEARN_DISPONIBLE = False


# ---------------------------------------------------------------------------
# Resultado de la discretización
# ---------------------------------------------------------------------------

@dataclass
class ResultadoDiscretizacion:
    """Resultado del pre-procesamiento numérico."""
    criterios_prolog: list[str] = field(default_factory=list)
    """Criterios canónicos listos para pasar a motor.buscar()."""
    etiquetas_meta: dict[str, str] = field(default_factory=dict)
    """Etiquetas descriptivas de las variables (para mostrar en la UI)."""
    advertencias: list[str] = field(default_factory=list)
    """Avisos sobre valores fuera de rango o conversiones aproximadas."""
    sklearn_usado: bool = False
    """True si scikit-learn participó en alguna discretización."""

    def a_dict(self) -> dict[str, Any]:
        return {
            "criterios_prolog": self.criterios_prolog,
            "etiquetas_meta": self.etiquetas_meta,
            "advertencias": self.advertencias,
            "sklearn_usado": self.sklearn_usado,
        }


# ---------------------------------------------------------------------------
# Heurísticas por variable
# ---------------------------------------------------------------------------

def _discretizar_edad(edad: float, resultado: ResultadoDiscretizacion) -> None:
    """Edad del espectador → criterios de público objetivo."""
    if not (0 <= edad <= 120):
        resultado.advertencias.append(
            f"Edad {edad} fuera del rango 0-120; se ignorará."
        )
        return
    edad = int(round(edad))
    if edad <= 10:
        resultado.criterios_prolog.append("infantil")
        resultado.etiquetas_meta["publico"] = f"Infantil (≤10 años: {edad})"
    elif edad <= 15:
        resultado.criterios_prolog.append("familiar")
        resultado.etiquetas_meta["publico"] = f"Pre-adolescente (11-15 años: {edad})"
    elif edad <= 25:
        resultado.etiquetas_meta["publico"] = f"Joven adulto (16-25 años: {edad})"
        # Sin restricción extra
    else:
        resultado.etiquetas_meta["publico"] = f"Adulto ({edad} años)"


def _discretizar_duracion(duracion_min: float, resultado: ResultadoDiscretizacion) -> None:
    """Duración en minutos → meta-etiqueta descriptiva."""
    if duracion_min < 0:
        resultado.advertencias.append("Duración negativa ignorada.")
        return
    if duracion_min < 70:
        etiqueta = "Corta (<70 min)"
    elif duracion_min <= 110:
        etiqueta = "Media (70-110 min)"
    elif duracion_min <= 160:
        etiqueta = "Larga (111-160 min)"
    else:
        etiqueta = "Muy larga (>160 min)"
    resultado.etiquetas_meta["duracion"] = etiqueta


def _discretizar_anio(anio: float, resultado: ResultadoDiscretizacion) -> None:
    """Año de estreno → meta-etiqueta de época."""
    anio = int(round(anio))
    if anio < 1980:
        etiqueta = "Clásica (<1980)"
    elif anio < 2000:
        etiqueta = "De los 80-90s"
    elif anio < 2010:
        etiqueta = "2000s"
    elif anio < 2020:
        etiqueta = "2010s"
    else:
        etiqueta = "Reciente (2020+)"
    resultado.etiquetas_meta["epoca"] = etiqueta


def _discretizar_temperatura(temp_c: float, resultado: ResultadoDiscretizacion) -> None:
    """Temperatura ambiente → sugerencia de género (elemento heurístico ilustrativo).

    Esta heurística es puramente demostrativa del concepto de pre-procesamiento
    de variables continuas del mundo real.
    """
    if temp_c < 10:
        criterio = "terror"
        etiqueta = f"Frío ({temp_c}°C) → sugerencia: terror o suspenso"
    elif temp_c < 20:
        criterio = "drama"
        etiqueta = f"Templado ({temp_c}°C) → sugerencia: drama o romance"
    elif temp_c < 30:
        criterio = "aventura"
        etiqueta = f"Cálido ({temp_c}°C) → sugerencia: aventura o animación"
    else:
        criterio = "divertida"
        etiqueta = f"Caluroso ({temp_c}°C) → sugerencia: comedia o animación"
    resultado.criterios_prolog.append(criterio)
    resultado.etiquetas_meta["temperatura"] = etiqueta


def _discretizar_calificacion(calificacion: float, resultado: ResultadoDiscretizacion) -> None:
    """Calificación de referencia → meta-etiqueta de calidad percibida."""
    if not (1.0 <= calificacion <= 10.0):
        resultado.advertencias.append(
            f"Calificación {calificacion} fuera del rango 1-10."
        )
        return
    if calificacion >= 8.0:
        etiqueta = f"Alta calificación ({calificacion:.1f}/10)"
    elif calificacion >= 6.0:
        etiqueta = f"Calificación media ({calificacion:.1f}/10)"
    else:
        etiqueta = f"Calificación baja ({calificacion:.1f}/10)"
    resultado.etiquetas_meta["calificacion_referencia"] = etiqueta


# ---------------------------------------------------------------------------
# Clasificador sklearn (opcional, ilustrativo)
# ---------------------------------------------------------------------------

class ClasificadorEdadSklearn:
    """Discretizador de edad con KBinsDiscretizer de scikit-learn.

    Muestra cómo se integraría un clasificador ligero de sklearn con el
    pre-procesamiento numérico antes de inyectar hechos a Prolog.

    Los bins son: [0,10], [11,15], [16,120] → infantil, familiar, adulto.
    """

    # Frontera de bins calibradas para 3 categorías
    _LIMITES = [0, 10, 15, 120]
    _ETIQUETAS = ["infantil", "familiar", "adulto"]

    def __init__(self) -> None:
        if not _SKLEARN_DISPONIBLE:
            raise ImportError(
                "scikit-learn no está instalado. "
                "Ejecuta: pip install scikit-learn numpy"
            )
        self._disc = KBinsDiscretizer(
            n_bins=3,
            encode="ordinal",
            strategy="quantile",
        )
        # Entrena con una muestra representativa del rango 0-120
        muestras = np.array(
            list(range(0, 11)) +           # infantil 0-10
            list(range(11, 16)) +          # familiar 11-15
            list(range(16, 121))           # adulto 16-120
        ).reshape(-1, 1)
        self._disc.fit(muestras)

    def predecir(self, edad: float) -> str:
        """Devuelve el criterio canónico para la edad dada."""
        x = np.array([[float(edad)]])
        bin_idx = int(self._disc.transform(x)[0][0])
        # Clamp por si el valor cae fuera del rango de entrenamiento
        bin_idx = max(0, min(bin_idx, len(self._ETIQUETAS) - 1))
        return self._ETIQUETAS[bin_idx]


# ---------------------------------------------------------------------------
# API pública
# ---------------------------------------------------------------------------

def discretizar(variables: dict[str, Any]) -> ResultadoDiscretizacion:
    """Convierte un diccionario de variables numéricas en criterios para Prolog.

    Parámetros reconocidos:
        edad_espectador (int|float)   : edad del espectador
        duracion_min (int|float)      : duración de la película en minutos
        anio_estreno (int|float)      : año de estreno preferido
        temperatura_c (float)         : temperatura ambiente en °C (opcional/ilustrativo)
        calificacion_ref (float 1-10) : calificación de referencia (IMDb-like)
        usar_sklearn (bool)           : si True y sklearn disponible, usa el clasificador

    Devuelve:
        ResultadoDiscretizacion con criterios_prolog y metadatos.
    """
    resultado = ResultadoDiscretizacion()
    usar_sklearn = bool(variables.get("usar_sklearn", False))

    # --- edad_espectador ---
    if "edad_espectador" in variables:
        try:
            edad = float(variables["edad_espectador"])
            if usar_sklearn and _SKLEARN_DISPONIBLE:
                try:
                    clf = ClasificadorEdadSklearn()
                    criterio = clf.predecir(edad)
                    if criterio in ("infantil", "familiar"):
                        resultado.criterios_prolog.append(criterio)
                    resultado.etiquetas_meta["publico"] = (
                        f"sklearn→{criterio} (edad {int(edad)})"
                    )
                    resultado.sklearn_usado = True
                except Exception as exc:
                    resultado.advertencias.append(f"sklearn falló: {exc}; usando heurística.")
                    _discretizar_edad(edad, resultado)
            else:
                _discretizar_edad(edad, resultado)
        except (TypeError, ValueError):
            resultado.advertencias.append("edad_espectador no es numérica; ignorada.")

    # --- duracion_min ---
    if "duracion_min" in variables:
        try:
            _discretizar_duracion(float(variables["duracion_min"]), resultado)
        except (TypeError, ValueError):
            resultado.advertencias.append("duracion_min no es numérica; ignorada.")

    # --- anio_estreno ---
    if "anio_estreno" in variables:
        try:
            _discretizar_anio(float(variables["anio_estreno"]), resultado)
        except (TypeError, ValueError):
            resultado.advertencias.append("anio_estreno no es numérico; ignorado.")

    # --- temperatura_c ---
    if "temperatura_c" in variables:
        try:
            _discretizar_temperatura(float(variables["temperatura_c"]), resultado)
        except (TypeError, ValueError):
            resultado.advertencias.append("temperatura_c no es numérica; ignorada.")

    # --- calificacion_ref ---
    if "calificacion_ref" in variables:
        try:
            _discretizar_calificacion(float(variables["calificacion_ref"]), resultado)
        except (TypeError, ValueError):
            resultado.advertencias.append("calificacion_ref no es numérica; ignorada.")

    # Deduplicar criterios
    vistos: set[str] = set()
    unicos: list[str] = []
    for c in resultado.criterios_prolog:
        if c not in vistos:
            vistos.add(c)
            unicos.append(c)
    resultado.criterios_prolog = unicos

    return resultado


def discretizar_a_consulta(variables: dict[str, Any]) -> str:
    """Atajo: devuelve los criterios como cadena de texto lista para ``motor.buscar()``.

    Ejemplo: discretizar_a_consulta({"edad_espectador": 8}) → "infantil"
    """
    res = discretizar(variables)
    return " ".join(res.criterios_prolog) if res.criterios_prolog else ""

