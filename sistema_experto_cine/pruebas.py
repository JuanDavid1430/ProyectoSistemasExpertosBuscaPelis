"""Pruebas de integración de búsqueda, caja blanca y recomendación."""

from __future__ import annotations

from pathlib import Path
from tempfile import TemporaryDirectory

from motor import MotorCine


def ids(datos: dict) -> set[str]:
    return {pelicula["id"] for pelicula in datos["resultados"]}


def reglas(datos: dict) -> set[str]:
    return {regla["id"] for regla in datos["auditoria"]["reglas_disparadas"]}


def ejecutar(nombre: str, prueba) -> bool:
    try:
        prueba()
    except Exception as exc:
        print(f"[FALLO] {nombre}: {type(exc).__name__}: {exc}")
        return False
    print(f"[OK]    {nombre}")
    return True


def main() -> int:
    temporal = TemporaryDirectory()
    motor = MotorCine(ruta_datos=Path(temporal.name) / "resenas_prueba.db")

    def caso_definitivo() -> None:
        datos = motor.buscar("películas de romance")
        assert ids(datos) == {"titanic"}
        assert datos["decision"]["estado"] == "definitiva"
        assert datos["auditoria"]["hipotesis_principal"] == "titanic"
        assert {"r02", "r13", "r24", "r25"} <= reglas(datos)
        assert any("genero(titanic, romance)" in h for h in datos["auditoria"]["hechos_verdaderos"])

    def caso_empate() -> None:
        datos = motor.buscar("películas divertidas")
        competencia = {h["id"] for h in datos["decision"]["hipotesis_competencia"]}
        assert datos["decision"]["estado"] == "evidencia_insuficiente"
        assert {"deadpool", "shrek", "toy_story", "villano"} == competencia
        assert datos["decision"]["recomendacion"]["criterio"] == "infantil"

    def caso_exclusion() -> None:
        datos = motor.buscar("películas para niños", edad=7)
        assert {"toy_story", "coco", "shrek"} <= ids(datos)
        assert "caso_terror_infantil" not in ids(datos)
        descartes = datos["auditoria"]["hipotesis_descartadas"]
        assert any(d["id"] == "caso_terror_infantil" and "excluyente" in d["motivo"] for d in descartes)

    def caso_edad() -> None:
        datos = motor.buscar("películas divertidas", edad=5)
        assert "shrek" in ids(datos)
        assert {"deadpool", "el_conjuro", "hotel"}.isdisjoint(ids(datos))

    def caso_cobertura() -> None:
        datos = motor.buscar("animación de aventura")
        por_id = {p["id"]: p for p in datos["resultados"]}
        assert por_id["toy_story"]["cobertura"] == 2
        assert por_id["nemo"]["nivel_coincidencia"] == "muy_alta"

    def caso_vacio() -> None:
        datos = motor.buscar("   ")
        assert datos["estado"] == "consulta_vacia"
        assert datos["resultados"] == []

    def caso_desconocido() -> None:
        datos = motor.buscar("películas intergalácticas")
        assert datos["estado"] == "criterio_no_reconocido"
        assert datos["decision"]["estado"] == "sin_candidatos"

    def caso_deduplicacion() -> None:
        datos = motor.buscar("divertidas graciosas divertidas")
        assert datos["criterios"] == ["divertida"]
        assert len(datos["resultados"]) == len(ids(datos))

    def caso_busqueda_por_titulo() -> None:
        consultas = {
            "Toy Story": "toy_story",
            "El Conjuro": "el_conjuro",
            "Buscando a Nemo": "nemo",
            "Mi villano favorito": "villano",
            "Joker": "joker",
        }
        for consulta, esperado in consultas.items():
            datos = motor.buscar(consulta)
            assert ids(datos) == {esperado}
            assert datos["decision"]["estado"] == "definitiva"
            assert datos["resultados"][0]["origen_principal"] == "titulo"
            assert "r18" in reglas(datos)

    def caso_consulta_para_ninos() -> None:
        esperadas = {
            "coco", "coraline", "encanto", "hotel", "intensamente",
            "nemo", "shrek", "toy_story", "villano",
        }
        con_tilde = motor.buscar("películas para niños")
        sin_tilde = motor.buscar("peliculas para ninos")
        assert ids(con_tilde) == esperadas
        assert ids(sin_tilde) == esperadas
        assert con_tilde["criterios"] == ["infantil"]

    def caso_inyeccion() -> None:
        datos = motor.buscar("terror\"), halt, pelicula(\"")
        assert datos["estado"] in {"ok", "criterio_no_reconocido"}

    def caso_validacion() -> None:
        try:
            motor.buscar("terror", edad=-2)
        except ValueError:
            return
        raise AssertionError("Una edad negativa debió ser rechazada")

    def caso_resena_persistente() -> None:
        respuesta = motor.agregar_resena(
            "toy_story",
            "Laura Prueba",
            "Una aventura cálida que funciona muy bien para ver en familia.",
            "familiar",
            5,
        )
        detalle = motor.detalle("toy_story")
        busqueda = motor.buscar("películas divertidas")
        assert respuesta["ok"] is True
        assert respuesta["activa_inferencia"] is False
        assert detalle["total_resenas"] == 3
        assert detalle["calificacion_promedio"] == 5
        assert busqueda["resultados"][0]["id"] == "toy_story"

    def caso_resenas_activan_inferencia() -> None:
        motor.agregar_resena(
            "titanic", "Ana Prueba",
            "La historia resulta emocionante y mantiene el interés hasta el final.",
            "emocionante", 4,
        )
        segunda = motor.agregar_resena(
            "titanic", "Luis Prueba",
            "Es una película emocionante por el viaje y las decisiones de sus personajes.",
            "emocionante", 5,
        )
        datos = motor.buscar("películas emocionantes")
        assert segunda["activa_inferencia"] is True
        assert segunda["autores_percepcion"] == 2
        assert "titanic" in ids(datos)

    casos = [
        ("inferencia definitiva + traza", caso_definitivo),
        ("empate + pregunta de desempate", caso_empate),
        ("negación y condición excluyente", caso_exclusion),
        ("filtro etario", caso_edad),
        ("cobertura de varios criterios", caso_cobertura),
        ("consulta vacía", caso_vacio),
        ("criterio desconocido", caso_desconocido),
        ("sinónimos y deduplicación", caso_deduplicacion),
        ("búsqueda directa por título", caso_busqueda_por_titulo),
        ("consulta películas para niños", caso_consulta_para_ninos),
        ("entrada tratada como dato", caso_inyeccion),
        ("validación de edad en el puente", caso_validacion),
        ("persistencia y ranking por reseña", caso_resena_persistente),
        ("reseñas recurrentes activan inferencia", caso_resenas_activan_inferencia),
    ]
    aprobadas = sum(ejecutar(nombre, prueba) for nombre, prueba in casos)
    print(f"\nRESULTADO: {aprobadas}/{len(casos)} pruebas aprobadas")
    motor.cerrar()
    temporal.cleanup()
    return 0 if aprobadas == len(casos) else 1


if __name__ == "__main__":
    raise SystemExit(main())
