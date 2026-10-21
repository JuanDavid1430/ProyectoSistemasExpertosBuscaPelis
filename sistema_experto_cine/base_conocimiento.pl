/* CineExperto - motor de reglas del Entregable 1.
   Edades y reseñas: datos DIDÁCTICOS, NO clasificaciones oficiales.
   Arquitectura acíclica: hechos -> nivel 1 -> nivel 2 -> nivel 3.
*/
:- encoding(utf8).
:- use_module(library(http/json)).
:- use_module(library(lists)).

% HECHOS agrupados por predicado; todos tienen aridad >= 2.
% pelicula(+Id,+Titulo,+Anio).
pelicula(el_conjuro, 'El Conjuro', 2013).
pelicula(it, 'It', 2017).
pelicula(annabelle, 'Annabelle', 2014).
pelicula(toy_story, 'Toy Story', 1995).
pelicula(nemo, 'Buscando a Nemo', 2003).
pelicula(intensamente, 'Intensamente', 2015).
pelicula(coco, 'Coco', 2017).
pelicula(encanto, 'Encanto', 2021).
pelicula(shrek, 'Shrek', 2001).
pelicula(villano, 'Mi villano favorito', 2010).
pelicula(deadpool, 'Deadpool', 2016).
pelicula(joker, 'Joker', 2019).
pelicula(coraline, 'Coraline', 2009).
pelicula(hotel, 'Hotel Transilvania', 2012).
pelicula(titanic, 'Titanic', 1997).
% Registro sintético: datos contradictorios para probar el descarte con \+.
pelicula(caso_terror_infantil, 'Caso de prueba: terror infantil', 2026).

% genero(+Pelicula,+Genero): clasificacion editorial, NO inferida de opiniones.
genero(el_conjuro, terror).
genero(it, terror).
genero(annabelle, terror).
genero(toy_story, animacion).
genero(toy_story, aventura).
genero(nemo, animacion).
genero(nemo, aventura).
genero(intensamente, animacion).
genero(coco, animacion).
genero(encanto, animacion).
genero(shrek, animacion).
genero(shrek, comedia).
genero(villano, animacion).
genero(villano, comedia).
genero(deadpool, accion).
genero(deadpool, comedia).
genero(joker, drama).
genero(coraline, animacion).
genero(coraline, fantasia).
genero(hotel, animacion).
genero(hotel, comedia).
genero(titanic, drama).
genero(titanic, romance).
genero(caso_terror_infantil, terror).

% etiqueta(+Pelicula,+Etiqueta): etiquetas agregadas por un editor.
etiqueta(el_conjuro, paranormal).
etiqueta(it, suspenso).
etiqueta(annabelle, paranormal).
etiqueta(toy_story, infantil).
etiqueta(toy_story, familiar).
etiqueta(toy_story, divertida).
etiqueta(nemo, infantil).
etiqueta(nemo, familiar).
etiqueta(intensamente, infantil).
etiqueta(intensamente, familiar).
etiqueta(coco, familiar).
etiqueta(encanto, infantil).
etiqueta(encanto, familiar).
etiqueta(shrek, infantil).
etiqueta(shrek, familiar).
etiqueta(shrek, divertida).
etiqueta(villano, infantil).
etiqueta(villano, divertida).
etiqueta(deadpool, divertida).
etiqueta(joker, oscura).
etiqueta(coraline, familiar).
etiqueta(hotel, infantil).
etiqueta(hotel, familiar).
etiqueta(titanic, romantica).
etiqueta(caso_terror_infantil, infantil).

% edad_minima(+Pelicula,+Anios): cifras ilustrativas del prototipo.
edad_minima(el_conjuro, 16).
edad_minima(it, 16).
edad_minima(annabelle, 16).
edad_minima(toy_story, 0).
edad_minima(nemo, 0).
edad_minima(intensamente, 0).
edad_minima(coco, 7).
edad_minima(encanto, 0).
edad_minima(shrek, 0).
edad_minima(villano, 0).
edad_minima(deadpool, 16).
edad_minima(joker, 16).
edad_minima(coraline, 10).
edad_minima(hotel, 7).
edad_minima(titanic, 12).
edad_minima(caso_terror_infantil, 7).

% sinopsis(+Pelicula,+Texto).
sinopsis(el_conjuro, 'Investigadores ayudan a una familia amenazada por una presencia paranormal.').
sinopsis(it, 'Un grupo de amigos enfrenta un mal sobrenatural en su pueblo.').
sinopsis(annabelle, 'Una muneca misteriosa genera sucesos inquietantes.').
sinopsis(toy_story, 'Los juguetes tienen una aventura mientras su dueno no esta.').
sinopsis(nemo, 'Un padre recorre el oceano en busca de su hijo.').
sinopsis(intensamente, 'Las emociones de una nina afrontan cambios familiares.').
sinopsis(coco, 'Un nino descubre su historia familiar gracias a la musica.').
sinopsis(encanto, 'Una familia con dones vive en una casa magica.').
sinopsis(shrek, 'Un ogro emprende una aventura con situaciones humoristicas.').
sinopsis(villano, 'Un villano conoce a tres ninas y cambia sus planes.').
sinopsis(deadpool, 'Un antiheroe se enfrenta a peligros con humor irreverente.').
sinopsis(joker, 'Un hombre experimenta una transformacion personal oscura.').
sinopsis(coraline, 'Una nina descubre un mundo alternativo inquietante.').
sinopsis(hotel, 'Un hotel de monstruos recibe una visita inesperada.').
sinopsis(titanic, 'Dos jovenes se enamoran durante un viaje maritimo.').
sinopsis(caso_terror_infantil, 'Registro sintético con etiqueta infantil y genero terror contradictorios.').

% tema_sinopsis(+Pelicula,+Tema): índice semántico manual de sinopsis.
tema_sinopsis(el_conjuro, paranormal).
tema_sinopsis(it, suspenso).
tema_sinopsis(annabelle, paranormal).
tema_sinopsis(toy_story, aventura).
tema_sinopsis(nemo, aventura).
tema_sinopsis(intensamente, emociones).
tema_sinopsis(coco, musical).
tema_sinopsis(encanto, musical).
tema_sinopsis(shrek, divertida).
tema_sinopsis(villano, divertida).
tema_sinopsis(deadpool, divertida).
tema_sinopsis(joker, drama).
tema_sinopsis(coraline, fantasia).
tema_sinopsis(hotel, divertida).
tema_sinopsis(titanic, romance).
tema_sinopsis(caso_terror_infantil, suspenso).

% opinion(+Pelicula,+Revisor,+Texto,+Percepcion). Datos FICTICIOS.
opinion(el_conjuro, ana, 'Nos reimos de algunas escenas.', divertida).
opinion(el_conjuro, luis, 'Fue divertido verla con amigos.', divertida).
opinion(el_conjuro, sara, 'Me dio mucho miedo.', terror).
opinion(it, camila, 'Fue aterradora.', terror).
opinion(it, juan, 'Me asusto bastante.', terror).
opinion(annabelle, diego, 'Tiene escenas de miedo.', terror).
opinion(toy_story, monica, 'Muy divertida.', divertida).
opinion(toy_story, pedro, 'Mis hijos se rieron.', divertida).
opinion(shrek, maria, 'Me hizo reir.', divertida).
opinion(shrek, sofia, 'Muy graciosa.', divertida).
opinion(coco, pablo, 'Una historia emotiva.', emocionante).
opinion(encanto, elena, 'Una aventura alegre.', alegre).
opinion(deadpool, carlos, 'Muy divertida.', divertida).
opinion(deadpool, rosa, 'Reimos con las bromas.', divertida).
opinion(joker, ramon, 'Una escena me parecio divertida.', divertida).
opinion(hotel, lucia, 'Muy graciosa.', divertida).
opinion(hotel, andres, 'Nos hizo reir.', divertida).

% sinonimo(+Token,+CriterioCanonico): traduce lenguaje de búsqueda.
sinonimo(terror, terror).
sinonimo(miedo, terror).
sinonimo(aterradoras, terror).
sinonimo(divertida, divertida).
sinonimo(divertidas, divertida).
sinonimo(divertido, divertida).
sinonimo(divertidos, divertida).
sinonimo(graciosa, divertida).
sinonimo(graciosas, divertida).
sinonimo(humor, divertida).
sinonimo(feliz, divertida).
sinonimo(alegre, divertida).
sinonimo(alegres, divertida).
sinonimo(ninos, infantil).
sinonimo('niños', infantil).
sinonimo(ninas, infantil).
sinonimo('niñas', infantil).
sinonimo(infantil, infantil).
sinonimo(infantiles, infantil).
sinonimo(familiar, familiar).
sinonimo(familia, familiar).
sinonimo(animacion, animacion).
sinonimo(animadas, animacion).
sinonimo(comedia, comedia).
sinonimo(aventura, aventura).
sinonimo(aventuras, aventura).
sinonimo(drama, drama).
sinonimo(romance, romance).
sinonimo(musical, musical).
sinonimo(musicales, musical).
sinonimo(fantasia, fantasia).
sinonimo(paranormal, paranormal).
sinonimo(suspenso, suspenso).

% NIVEL 1: validaciones sobre hechos y entradas.
% R01
pelicula_valida(P) :- pelicula(P, _, _).
% R02
genero_validado(P, G) :- pelicula_valida(P), genero(P, G).
% R03
etiqueta_validada(P, E) :- pelicula_valida(P), etiqueta(P, E).
% R04
tema_validado(P, T) :- pelicula_valida(P), sinopsis(P, _), tema_sinopsis(P, T).
% R05
edad_valida(P, Min) :- pelicula_valida(P), edad_minima(P, Min), integer(Min), Min >= 0.
% R06
edad_compatible(P, Edad) :- integer(Edad), Edad >= 0, edad_valida(P, Min), Edad >= Min.
% R07: corte exclusivo para la ausencia de filtro de edad (-1).
edad_habilitada(P, -1) :- pelicula_valida(P), !.
edad_habilitada(P, Edad) :- edad_compatible(P, Edad).
% R08
opinion_validada(P, Autor, Tema) :- pelicula_valida(P), opinion(P, Autor, _, Tema).
% R09
contenido_de_terror(P) :- genero_validado(P, terror).

% NIVEL 2: inferencias intermedias; no consultan solo hechos.
% R10
orientacion_infantil(P) :- etiqueta_validada(P, infantil).
orientacion_infantil(P) :- etiqueta_validada(P, familiar).
% R11: dos revisores distintos evitan peso a opiniones individuales.
percepcion_recurrente(P, Tema, Total) :-
    pelicula_valida(P),
    findall(Autor, opinion_validada(P, Autor, Tema), Autores),
    sort(Autores, Unicos), length(Unicos, Total), Total >= 2.
% R12: negacion por fallo con P ya instanciada; opiniones NO otorgan aptitud infantil.
apta_para_ninos(P) :-
    edad_valida(P, Min), Min =< 10,
    orientacion_infantil(P),
    \+ contenido_de_terror(P).
% R13
coincidencia_genero(P, C, genero, Motivo) :-
    genero_validado(P, C), format(atom(Motivo), 'Genero editorial: ~w.', [C]).
% R14
coincidencia_etiqueta(P, C, etiqueta, Motivo) :-
    etiqueta_validada(P, C), format(atom(Motivo), 'Etiqueta editorial: ~w.', [C]).
% R15
coincidencia_sinopsis(P, C, sinopsis, Motivo) :-
    tema_validado(P, C), format(atom(Motivo), 'Tema indexado de sinopsis: ~w.', [C]).
% R16
coincidencia_opinion(P, C, opiniones, Motivo) :-
    percepcion_recurrente(P, C, Total),
    format(atom(Motivo), '~d autores comentaron ~w; no define el genero.', [Total, C]).
% R17
coincidencia_infantil(P, infantil, clasificacion_infantil, Motivo) :-
    apta_para_ninos(P), edad_minima(P, Min),
    format(atom(Motivo), 'Apta para ninos segun reglas didacticas desde ~d anos.', [Min]).

% NIVEL 3: combinación, prioridad, deduplicación, salida.
% R18
coincidencia(P, C, F, M) :- coincidencia_genero(P, C, F, M).
coincidencia(P, C, F, M) :- coincidencia_etiqueta(P, C, F, M).
coincidencia(P, C, F, M) :- coincidencia_sinopsis(P, C, F, M).
coincidencia(P, C, F, M) :- coincidencia_opinion(P, C, F, M).
coincidencia(P, C, F, M) :- coincidencia_infantil(P, C, F, M).
% R19: cortes: fuente de evidencia instanciada, alternativas excluyentes y fallback.
puntaje_fuente(clasificacion_infantil, 100) :- !.
puntaje_fuente(genero, 95) :- !.
puntaje_fuente(etiqueta, 85) :- !.
puntaje_fuente(sinopsis, 70) :- !.
puntaje_fuente(opiniones, 55) :- !.
puntaje_fuente(_, 20).
% R20: prioridad de coincidencia, no clasificacion de edad de la pelicula.
prioridad_de_puntaje(Puntaje, alta) :- Puntaje >= 85, !.
prioridad_de_puntaje(Puntaje, media) :- Puntaje >= 55, !.
prioridad_de_puntaje(_, baja).
% R21
evidencia(P, C, evidencia(Puntos, C, Fuente, Motivo)) :-
    coincidencia(P, C, Fuente, Motivo), puntaje_fuente(Fuente, Puntos).
% R22: selección determinista del mayor puntaje sin ciclos infinitos.
mejor_evidencia([Primera|Resto], Mejor) :- mejor_aux(Resto, Primera, Mejor).
mejor_aux([], Mejor, Mejor).
mejor_aux([Actual|Resto], Acumulado, Mejor) :-
    Actual = evidencia(PAct, _, _, _), Acumulado = evidencia(PAnt, _, _, _),
    ( PAct > PAnt -> Siguiente = Actual ; Siguiente = Acumulado ),
    mejor_aux(Resto, Siguiente, Mejor).
% R23
evidencia_dict(evidencia(Puntos, C, Fuente, Motivo),
               _{criterio:C, origen:Fuente, justificacion:Motivo, puntaje:Puntos}).
% R24
resultado_para(Criterios, P,
    _{id:P, titulo:Titulo, anio:Anio, edad_minima:Min, generos:Generos,
      sinopsis:Resumen, prioridad:Prioridad, puntaje:Puntaje,
      origen_principal:Fuente, justificacion_principal:Motivo, evidencias:Evidencias}) :-
    pelicula(P, Titulo, Anio), edad_valida(P, Min), sinopsis(P, Resumen),
    findall(G, genero_validado(P, G), GRaw), sort(GRaw, Generos),
    findall(E, (member(C, Criterios), criterio_admisible(P, C),
                evidencia(P, C, E)), ERaw),
    sort(ERaw, EUnicas),
    mejor_evidencia(EUnicas, evidencia(Puntaje, _, Fuente, Motivo)),
    prioridad_de_puntaje(Puntaje, Prioridad),
    maplist(evidencia_dict, EUnicas, Evidencias).
% R25: findall + sort elimina peliculas repetidas y acepta lista vacia.
buscar_peliculas(Criterios, Edad, Resultados) :-
    is_list(Criterios), integer(Edad), Edad >= -1,
    findall(P, (member(C, Criterios), coincidencia(P, C, _, _),
                criterio_admisible(P, C), edad_habilitada(P, Edad)), Duplicados),
    sort(Duplicados, Unicos),
    maplist(resultado_para(Criterios), Unicos, SinOrden),
    findall(Orden-Resultado,
        (member(Resultado, SinOrden), get_dict(puntaje, Resultado, Puntos),
         Orden is -Puntos), Pares),
    keysort(Pares, Ordenados),
    findall(Resultado, member(_-Resultado, Ordenados), Resultados).
% R26: interpretación del texto de consulta SOLO EN PROLOG.
consulta_a_criterios(Consulta, Criterios) :-
    ( atom(Consulta) -> atom_string(Consulta, Texto)
    ; string(Consulta) -> Texto = Consulta
    ; Texto = "" ),
    string_lower(Texto, Minusculas),
    split_string(Minusculas, " \t\n\r,.;:!?¿¡", " \t\n\r", Palabras),
    findall(C, (member(Palabra, Palabras), atom_string(Atom, Palabra),
                sinonimo(Atom, C)), Todos),
    sort(Todos, Criterios).
% R27: cortes excluyentes para estados y fallback de salida.
estado_consulta(Consulta, _, _, consulta_vacia) :-
    ( Consulta == "" ; Consulta == '' ), !.
estado_consulta(_, [], _, criterio_no_reconocido) :- !.
estado_consulta(_, _, [], sin_resultados) :- !.
estado_consulta(_, _, _, ok).
% R28: intercambia un JSON completo y no necesita analizar términos en Python.
buscar_json(Consulta, Edad, Json) :-
    consulta_a_criterios(Consulta, Criterios),
    buscar_peliculas(Criterios, Edad, Resultados),
    estado_consulta(Consulta, Criterios, Resultados, Estado),
    length(Resultados, Total),
    atom_json_dict(Json, _{consulta:Consulta, criterios:Criterios,
        edad_consultada:Edad, estado:Estado, total:Total,
        resultados:Resultados}, []).
buscar_json(Consulta, Json) :- buscar_json(Consulta, -1, Json).

% R29: filtros duros independientes de las opiniones o la sinopsis.
% Infantil exige aptitud validada; terror exige genero editorial terror.
% Los cortes evitan que un fallo caiga en la alternativa permisiva general.
criterio_admisible(P, infantil) :- !, apta_para_ninos(P).
criterio_admisible(P, terror) :- !, genero_validado(P, terror).
criterio_admisible(_, _).
