"""8 pruebas de integración por consola. Genera evidencia con redirección.

    python pruebas.py > evidencia_terminal.txt
"""
from motor import MotorCine, mostrar_resultado


def ids(datos):
    return {p["id"] for p in datos["resultados"]}


def pelicula(datos, clave):
    return next((p for p in datos["resultados"] if p["id"] == clave), {})


def main():
    motor = MotorCine()
    casos = [
        (
            "Normal 1 - diagnóstico único claro", "películas de romance", None,
            "Únicamente Titanic (género romance)",
            lambda d: ids(d) == {"titanic"} and
            pelicula(d, "titanic").get("origen_principal") == "genero",
        ),
        (
            "Normal 2 - múltiples evidencias y recolección", "películas divertidas", None,
            "El Conjuro y Shrek incluidos; Conjuro se justifica por opiniones",
            lambda d: {"el_conjuro", "shrek"} <= ids(d)
            and pelicula(d, "el_conjuro").get("origen_principal") == "opiniones"
            and "terror" in pelicula(d, "el_conjuro")["generos"],
        ),
        (
            "Exclusión - aptitud infantil y negación", "películas para niños", 7,
            "Toy Story, Coco, Shrek sí; terror, Deadpool, Coraline y caso sintético no",
            lambda d: {"toy_story", "coco", "shrek"} <= ids(d)
            and {"el_conjuro", "deadpool", "coraline", "caso_terror_infantil"}.isdisjoint(ids(d)),
        ),
        (
            "Borde 1 - lista parcial por filtro etario", "películas divertidas", 5,
            "Shrek sí; El Conjuro y Deadpool no",
            lambda d: "shrek" in ids(d)
            and {"el_conjuro", "deadpool"}.isdisjoint(ids(d)),
        ),
        (
            "Borde 2 - entrada vacía y fallback", "", None,
            "consulta_vacia y lista de resultados vacía",
            lambda d: d["estado"] == "consulta_vacia" and d["resultados"] == [],
        ),
        (
            "Adicional - criterio desconocido", "películas intergalácticas", None,
            "criterio_no_reconocido sin lanzar una excepción",
            lambda d: d["estado"] == "criterio_no_reconocido" and d["resultados"] == [],
        ),
        (
            "Adicional - sinónimos y deduplicación", "divertidas graciosas divertidas", None,
            "Solo un criterio canónico y ninguna película duplicada",
            lambda d: d["criterios"] == ["divertida"] and
            len(d["resultados"]) == len(ids(d)),
        ),
        (
            "Adicional - buscar género terror", "películas de terror", None,
            "El Conjuro e It incluidos; Toy Story excluida",
            lambda d: {"el_conjuro", "it"} <= ids(d) and "toy_story" not in ids(d),
        ),
    ]
    aprobadas = 0
    for n, (nombre, consulta, edad, esperado, validar) in enumerate(casos, 1):
        print(f"\n{'=' * 72}\nPRUEBA {n}: {nombre}")
        print(f"Objetivo: {nombre}")
        print(f"Entrada: consulta={consulta!r}, edad={edad!r}")
        print(f"Consulta: buscar_json(Consulta, {edad if edad is not None else -1}, Json)")
        print(f"Esperado: {esperado}")
        try:
            obtenido = motor.buscar(consulta, edad)
            print(mostrar_resultado(obtenido))
            ok = validar(obtenido)
        except Exception as exc:
            print(f"ERROR: {type(exc).__name__}: {exc}")
            ok = False
        print(f"Obtenido: {'APROBADO' if ok else 'FALLÓ'}")
        aprobadas += ok
    print(f"\nRESULTADO GENERAL: {aprobadas}/{len(casos)} pruebas aprobadas")
    return 0 if aprobadas == len(casos) else 1


if __name__ == "__main__":
    raise SystemExit(main())
