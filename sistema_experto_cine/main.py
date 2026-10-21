"""Interfaz en consola para el Entregable 1 (dashboard reservado para fase futura)."""
from motor import MotorCine, mostrar_resultado


def main() -> None:
    motor = MotorCine()
    print("\n=== CineExperto: buscador experto de películas ===")
    print("Ejemplos: terror | películas divertidas | películas para niños")
    print("Escriba 'salir' para terminar.")
    while True:
        consulta = input("\nBuscar: ")
        if consulta.strip().lower() == "salir":
            break
        edad_txt = input("Edad del espectador [Enter = sin filtro]: ").strip()
        if edad_txt and not edad_txt.isdecimal():
            print("La edad debe ser un número entero no negativo.")
            continue
        edad = int(edad_txt) if edad_txt else None
        try:
            print(mostrar_resultado(motor.buscar(consulta, edad)))
        except Exception as exc:
            print(f"Error al consultar: {exc}")


if __name__ == "__main__":
    main()
