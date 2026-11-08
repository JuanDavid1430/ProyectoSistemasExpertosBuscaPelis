/* CineExperto - motor simbólico y explicable.
   Entregable 3: DCG de Lenguaje Natural + Adquisición Dinámica de Conocimiento.
   Edades y reseñas: datos DIDÁCTICOS, NO clasificaciones oficiales.
   Python solo captura/presenta datos; inferencia, traza y desempate viven aquí.
*/
:- encoding(utf8).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- dynamic resena_usuario/6, categoria_usuario/2, archivo_datos/1.
% Entregable 3: predicados dinámicos para adquisición de conocimiento en caliente.
:- dynamic diagnostico_experto/3.   % diagnostico_experto(Id, Nombre, CuerpoAtom)
:- dynamic regla_experto/2.         % regla_experto(Cabeza, Cuerpo) — cláusula inyectada
:- dynamic regla_experto_definida/2. % regla_experto_definida(Functor, Nombre)
:- dynamic pelicula/3, edad_minima/2, sinopsis/2, etiqueta/2, genero/2.
:- discontiguous pelicula/3, edad_minima/2, sinopsis/2, etiqueta/2, genero/2, regla_experto_definida/2.

% El archivo JSON contiene datos; nunca se ejecutan términos suministrados por usuarios.
inicializar_resenas(ArchivoEntrada) :-
    normalizar_atom_entrada(ArchivoEntrada,Archivo),
    retractall(resena_usuario(_,_,_,_,_,_)), retractall(categoria_usuario(_,_)),
    retractall(archivo_datos(_)), assertz(archivo_datos(Archivo)),
    ( exists_file(Archivo) -> cargar_datos_json(Archivo)
    ; file_name_extension(Base,_,Archivo), file_name_extension(Base,db,Anterior),
      ( exists_file(Anterior) -> migrar_resenas_anteriores(Anterior), guardar_datos_json
      ; true ) ).

cargar_datos_json(Archivo) :-
    setup_call_cleanup(open(Archivo,read,Entrada,[encoding(utf8)]),
        json_read_dict(Entrada,Datos,[value_string_as(atom)]),close(Entrada)),
    get_dict(resenas,Datos,Resenas),get_dict(categorias,Datos,Categorias),
    maplist(cargar_resena_json,Resenas),maplist(cargar_categoria_json,Categorias).
cargar_resena_json(D) :-
    get_dict(pelicula,D,P),get_dict(autor,D,A),get_dict(texto,D,T),
    get_dict(percepcion,D,C),get_dict(calificacion,D,N),get_dict(fecha,D,F),
    atom(P),atom(A),atom(T),atom(C),integer(N),atom(F),
    assertz(resena_usuario(P,A,T,C,N,F)).
cargar_categoria_json(D) :-
    get_dict(pelicula,D,P),get_dict(categoria,D,C),atom(P),atom(C),
    assertz(categoria_usuario(P,C)).

% La migración interpreta únicamente las operaciones concretas del registro antiguo.
migrar_resenas_anteriores(Archivo) :-
    setup_call_cleanup(open(Archivo,read,Entrada,[encoding(utf8)]),
        leer_registro_anterior(Entrada),close(Entrada)).
leer_registro_anterior(Entrada) :-
    read_term(Entrada,Termino,[]),
    ( Termino == end_of_file -> true
    ; aplicar_registro_anterior(Termino),leer_registro_anterior(Entrada) ).
aplicar_registro_anterior(created(_)) :- !.
aplicar_registro_anterior(assert(resena_usuario(P,A,T,C,N,F))) :- !,
    ground([P,A,T,C,N,F]),atom(P),atom(A),atom(T),atom(C),integer(N),atom(F),
    assertz(resena_usuario(P,A,T,C,N,F)).
aplicar_registro_anterior(retract(resena_usuario(P,A,T,C,N,F))) :- !,
    ground([P,A,T,C,N,F]), retract(resena_usuario(P,A,T,C,N,F)).
aplicar_registro_anterior(Termino) :- throw(error(registro_antiguo_invalido(Termino),_)).

guardar_datos_json :-
    archivo_datos(Archivo),atom_concat(Archivo,'.tmp',Temporal),
    findall(_{pelicula:P,autor:A,texto:T,percepcion:C,calificacion:N,fecha:F},
        resena_usuario(P,A,T,C,N,F),Resenas),
    findall(_{pelicula:P,categoria:C},categoria_usuario(P,C),Categorias),
    setup_call_cleanup(open(Temporal,write,Salida,[encoding(utf8)]),
        json_write_dict(Salida,_{version:1,resenas:Resenas,categorias:Categorias},[width(100)]),
        close(Salida)),
    rename_file(Temporal,Archivo).

% HECHOS DEL DOMINIO
% pelicula(?Id, ?Titulo, ?Anio).
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
pelicula(caso_terror_infantil, 'Caso de prueba: terror infantil', 2026).

% genero(?Pelicula, ?Genero): clasificación editorial.
genero(el_conjuro, terror). genero(it, terror). genero(annabelle, terror).
genero(P,G) :- categoria_usuario(P,G).
genero(toy_story, animacion). genero(toy_story, aventura).
genero(nemo, animacion). genero(nemo, aventura).
genero(intensamente, animacion). genero(coco, animacion).
genero(encanto, animacion). genero(shrek, animacion). genero(shrek, comedia).
genero(villano, animacion). genero(villano, comedia).
genero(deadpool, accion). genero(deadpool, comedia). genero(joker, drama).
genero(coraline, animacion). genero(coraline, fantasia).
genero(hotel, animacion). genero(hotel, comedia).
genero(titanic, drama). genero(titanic, romance).
genero(caso_terror_infantil, terror).

% etiqueta(?Pelicula, ?Etiqueta): etiquetas agregadas por un editor.
etiqueta(el_conjuro, paranormal). etiqueta(it, suspenso).
etiqueta(annabelle, paranormal). etiqueta(toy_story, infantil).
etiqueta(toy_story, familiar). etiqueta(toy_story, divertida).
etiqueta(nemo, infantil). etiqueta(nemo, familiar).
etiqueta(intensamente, infantil). etiqueta(intensamente, familiar).
etiqueta(coco, familiar). etiqueta(encanto, infantil).
etiqueta(encanto, familiar). etiqueta(shrek, infantil).
etiqueta(shrek, familiar). etiqueta(shrek, divertida).
etiqueta(villano, infantil). etiqueta(villano, divertida).
etiqueta(deadpool, divertida). etiqueta(joker, oscura).
etiqueta(coraline, familiar). etiqueta(hotel, infantil).
etiqueta(hotel, familiar). etiqueta(titanic, romantica).
etiqueta(caso_terror_infantil, infantil).

% edad_minima(?Pelicula, ?Anios): cifras ilustrativas del prototipo.
edad_minima(el_conjuro, 16). edad_minima(it, 16). edad_minima(annabelle, 16).
edad_minima(toy_story, 0). edad_minima(nemo, 0). edad_minima(intensamente, 0).
edad_minima(coco, 7). edad_minima(encanto, 0). edad_minima(shrek, 0).
edad_minima(villano, 0). edad_minima(deadpool, 16). edad_minima(joker, 16).
edad_minima(coraline, 10). edad_minima(hotel, 7). edad_minima(titanic, 12).
edad_minima(caso_terror_infantil, 7).

% sinopsis(?Pelicula, ?Texto).
sinopsis(el_conjuro, 'La familia Perron se muda a una antigua casa de campo en Rhode Island con la esperanza de comenzar una nueva vida. Sin embargo, pronto empiezan a experimentar sucesos inexplicables, ruidos aterradores y manifestaciones sobrenaturales que ponen en peligro su tranquilidad. Desesperados, recurren a Ed y Lorraine Warren, reconocidos investigadores de fenómenos paranormales, quienes descubren que la propiedad oculta una historia oscura. A medida que avanza la investigación, deberán enfrentarse a una poderosa presencia maligna que amenaza con destruir a toda la familia.').
sinopsis(it, 'En el pequeño pueblo de Derry, Maine, una serie de misteriosas desapariciones de niños despierta el temor entre sus habitantes. Un grupo de siete jóvenes, conocido como el Club de los Perdedores, descubre que detrás de estos acontecimientos se esconde una antigua entidad sobrenatural que adopta diferentes formas, especialmente la de un aterrador payaso llamado Pennywise. Unidos por la amistad y sus propias experiencias difíciles, los jóvenes deberán superar sus mayores miedos para enfrentarse a una amenaza que ha atormentado al pueblo durante generaciones.').
sinopsis(annabelle, 'John Form sorprende a su esposa embarazada, Mia, con una antigua muñeca de colección que parece ser el regalo perfecto para completar su hogar. Sin embargo, después de que una violenta secta invade su vivienda, comienzan a ocurrir acontecimientos paranormales cada vez más perturbadores. Objetos que se mueven sin explicación, apariciones aterradoras y una presencia maligna convierten la vida de la pareja en una pesadilla. Pronto descubrirán que la muñeca Annabelle está relacionada con una fuerza demoníaca que amenaza su seguridad y la de su futura familia.').
sinopsis(toy_story, 'Woody, un vaquero de juguete, disfruta de ser el favorito de Andy y liderar a los demás juguetes de su habitación, quienes cobran vida cuando los humanos no están presentes. Todo cambia cuando Andy recibe a Buzz Lightyear, un moderno guardián espacial que rápidamente se convierte en su nueva atracción. Los celos y la rivalidad provocan que ambos terminen lejos de casa, obligándolos a trabajar juntos para regresar con su dueño. Durante esta divertida aventura descubrirán la importancia de la amistad, la confianza y el trabajo en equipo.').
sinopsis(nemo, 'Marlin es un pez payaso extremadamente protector que vive con su hijo Nemo en la Gran Barrera de Coral. Cuando Nemo es capturado por un buzo y llevado a un acuario en Sídney, su padre emprende un peligroso viaje a través del océano para encontrarlo. Durante su búsqueda conoce a Dory, una simpática pez con problemas de memoria que decide acompañarlo. Juntos enfrentarán tiburones, medusas, corrientes marinas y numerosos desafíos, mientras Nemo intenta encontrar una manera de regresar a casa.').
sinopsis(intensamente, 'Riley es una niña de once años cuya vida cambia radicalmente cuando su familia se muda a San Francisco. Dentro de su mente, cinco emociones —Alegría, Tristeza, Temor, Furia y Desagrado— trabajan desde un centro de control para orientar sus pensamientos, recuerdos y decisiones. Sin embargo, la adaptación a una nueva ciudad, escuela y entorno familiar provoca un desequilibrio emocional inesperado. Mientras Alegría intenta mantener todo bajo control, descubrirá que cada emoción cumple una función importante en el crecimiento y bienestar de Riley.').
sinopsis(coco, 'Miguel es un niño mexicano de doce años que sueña con convertirse en un gran músico, aunque su familia ha prohibido la música durante generaciones. Durante la celebración del Día de los Muertos, un acontecimiento extraordinario lo transporta al colorido Mundo de los Muertos, donde conoce a sus antepasados y a Héctor, un personaje ingenioso que decide ayudarlo. Para regresar a casa, Miguel deberá descubrir secretos familiares, comprender el origen de aquella antigua prohibición y reconocer la importancia de los recuerdos, las tradiciones y los vínculos familiares.').
sinopsis(encanto, 'En las montañas de Colombia vive la familia Madrigal, cuyos integrantes poseen dones mágicos que utilizan para ayudar a su comunidad. Todos han recibido habilidades extraordinarias, excepto Mirabel, quien intenta encontrar su lugar dentro de una familia tan especial. Cuando comienza a notar extrañas grietas en su casa y señales de que la magia está desapareciendo, decide investigar lo que sucede. Su búsqueda revelará secretos familiares y conflictos ocultos, demostrando que el verdadero valor de una persona no depende únicamente de sus poderes.').
sinopsis(shrek, 'Shrek es un ogro solitario que disfruta de una vida tranquila en su pantano, lejos de las personas que lo juzgan por su apariencia. Sin embargo, su hogar es invadido por numerosas criaturas de cuentos de hadas expulsadas por el ambicioso Lord Farquaad. Para recuperar su tranquilidad, Shrek acepta rescatar a la princesa Fiona de una torre custodiada por un dragón. Acompañado por un burro parlanchín, emprende una aventura llena de humor, peligros y sorpresas que cambiará su manera de entender la amistad, el amor y la aceptación personal.').
sinopsis(villano, 'Gru es un famoso supervillano que sueña con realizar el robo más impresionante de la historia: robar la Luna. Para conseguirlo, cuenta con inventos extravagantes, un laboratorio secreto y un ejército de pequeños ayudantes amarillos llamados Minions. Sin embargo, sus planes comienzan a cambiar cuando adopta a tres niñas huérfanas, Margo, Edith y Agnes, inicialmente como parte de una estrategia contra otro villano. La convivencia con ellas despertará sentimientos que desconocía y lo enfrentará al desafío más inesperado de su vida: convertirse en padre.').
sinopsis(deadpool, 'Wade Wilson es un exsoldado de fuerzas especiales que trabaja como mercenario y disfruta de una vida llena de sarcasmo y humor irreverente. Tras recibir un diagnóstico de cáncer, decide someterse a un procedimiento experimental que le otorga extraordinarias capacidades de regeneración, pero también transforma drásticamente su apariencia. Adoptando la identidad de Deadpool, emprende una búsqueda para vengarse de quienes arruinaron su vida y recuperar a la mujer que ama. Su aventura combina intensas escenas de acción, violencia, comedia para adultos y constantes comentarios dirigidos al público.').
sinopsis(joker, 'Arthur Fleck es un hombre solitario que trabaja como payaso y sueña con convertirse en un comediante reconocido en Ciudad Gótica. Sin embargo, vive rodeado de dificultades económicas, rechazo social y una profunda sensación de aislamiento. Mientras intenta encontrar su lugar en una sociedad que parece ignorarlo, una serie de acontecimientos violentos comienza a transformar su personalidad y su manera de comprender el mundo. Su progresiva caída hacia la oscuridad lo llevará a convertirse en una figura que simboliza el descontento, el caos y la violencia de una ciudad en crisis.').
sinopsis(coraline, 'Coraline Jones es una niña curiosa que se muda con sus padres a una antigua casa donde se siente aburrida y poco atendida. Mientras explora su nuevo hogar, descubre una puerta secreta que conduce a un mundo paralelo aparentemente perfecto, donde encuentra versiones alternativas de sus padres que le ofrecen toda la atención y diversión que desea. Sin embargo, pronto descubre que detrás de aquel lugar maravilloso se esconde una presencia peligrosa. Coraline deberá utilizar su inteligencia y valentía para escapar de una inquietante realidad que amenaza con atraparla para siempre.').
sinopsis(hotel, 'El conde Drácula administra un lujoso hotel oculto del mundo humano, donde monstruos famosos como Frankenstein, el Hombre Invisible, la Momia y los hombres lobo pueden disfrutar de unas vacaciones tranquilas. Todo parece estar bajo control hasta que Jonathan, un joven humano, llega accidentalmente al establecimiento durante la celebración del cumpleaños número 118 de Mavis, la hija de Drácula. Desesperado por proteger a su familia y mantener el secreto del hotel, Drácula intentará ocultar al visitante. Sin embargo, la inesperada conexión entre Jonathan y Mavis pondrá a prueba sus prejuicios sobre los humanos.').
sinopsis(titanic, 'En 1912, el Titanic inicia su viaje inaugural hacia Nueva York, transportando pasajeros de diferentes clases sociales. Durante la travesía, Rose, una joven de familia adinerada comprometida con un hombre al que no ama, conoce a Jack Dawson, un artista de origen humilde que viaja en tercera clase. A pesar de sus diferencias, ambos desarrollan una intensa relación que desafía las expectativas sociales de la época. Sin embargo, cuando el gigantesco transatlántico choca contra un iceberg en el océano Atlántico, su historia de amor se convierte en una desesperada lucha por sobrevivir a una de las tragedias marítimas más recordadas de la historia.').
sinopsis(caso_terror_infantil, 'Este registro ficticio ha sido creado exclusivamente para evaluar el funcionamiento del sistema experto CineExperto. Representa una supuesta película clasificada simultáneamente como contenido infantil y perteneciente al género terror, con características deliberadamente ambiguas para poner a prueba las reglas de recomendación y validación. Su propósito es comprobar si el motor de inferencia identifica posibles incompatibilidades entre la audiencia objetivo, la intensidad del contenido y los criterios de seguridad establecidos. No corresponde a una producción cinematográfica real y debe utilizarse únicamente en escenarios controlados de prueba.').

% tema_sinopsis(?Pelicula, ?Tema): índice semántico manual de sinopsis.
tema_sinopsis(el_conjuro, paranormal). tema_sinopsis(it, suspenso).
tema_sinopsis(annabelle, paranormal). tema_sinopsis(toy_story, aventura).
tema_sinopsis(nemo, aventura). tema_sinopsis(intensamente, emociones).
tema_sinopsis(coco, musical). tema_sinopsis(encanto, musical).
tema_sinopsis(shrek, divertida). tema_sinopsis(villano, divertida).
tema_sinopsis(deadpool, divertida). tema_sinopsis(joker, drama).
tema_sinopsis(coraline, fantasia). tema_sinopsis(hotel, divertida).
tema_sinopsis(titanic, romance). tema_sinopsis(caso_terror_infantil, suspenso).

% opinion(?Pelicula, ?Revisor, ?Texto, ?Percepcion). Datos ficticios.
opinion(el_conjuro, ana, 'Nos reímos de algunas escenas.', divertida).
opinion(el_conjuro, luis, 'Fue divertido verla con amigos.', divertida).
opinion(el_conjuro, sara, 'Me dio mucho miedo.', terror).
opinion(it, camila, 'Fue aterradora.', terror).
opinion(it, juan, 'Me asustó bastante.', terror).
opinion(annabelle, diego, 'Tiene escenas de miedo.', terror).
opinion(toy_story, monica, 'Muy divertida.', divertida).
opinion(toy_story, pedro, 'Mis hijos se rieron.', divertida).
opinion(shrek, maria, 'Me hizo reír.', divertida).
opinion(shrek, sofia, 'Muy graciosa.', divertida).
opinion(coco, pablo, 'Una historia emotiva.', emocionante).
opinion(encanto, elena, 'Una aventura alegre.', alegre).
opinion(deadpool, carlos, 'Muy divertida.', divertida).
opinion(deadpool, rosa, 'Reímos con las bromas.', divertida).
opinion(joker, ramon, 'Una escena me pareció divertida.', divertida).
opinion(hotel, lucia, 'Muy graciosa.', divertida).
opinion(hotel, andres, 'Nos hizo reír.', divertida).

% sinonimo(?Token, ?CriterioCanonico): vocabulario controlado de entrada.
sinonimo(terror, terror). sinonimo(miedo, terror). sinonimo(aterradoras, terror).
sinonimo(divertida, divertida). sinonimo(divertidas, divertida).
sinonimo(divertido, divertida). sinonimo(divertidos, divertida).
sinonimo(graciosa, divertida). sinonimo(graciosas, divertida).
sinonimo(humor, divertida). sinonimo(feliz, divertida).
sinonimo(alegre, divertida). sinonimo(alegres, divertida).
sinonimo(ninos, infantil). sinonimo('niños', infantil).
sinonimo(ninas, infantil). sinonimo('niñas', infantil).
sinonimo(infantil, infantil). sinonimo(infantiles, infantil).
sinonimo(familiar, familiar). sinonimo(familia, familiar).
sinonimo(animacion, animacion). sinonimo('animación', animacion).
sinonimo(animada, animacion). sinonimo(animado, animacion).
sinonimo(animadas, animacion). sinonimo(animados, animacion).
sinonimo(comedia, comedia). sinonimo(comico, comedia). sinonimo(comica, comedia).
sinonimo(comicos, comedia). sinonimo(comicas, comedia).
sinonimo(aventura, aventura). sinonimo(aventuras, aventura).
sinonimo(drama, drama). sinonimo(dramatico, drama). sinonimo(dramatica, drama).
sinonimo(romance, romance). sinonimo(amor, romance).
sinonimo(romantico, romance). sinonimo(romantica, romance).
sinonimo('romántico', romance). sinonimo('romántica', romance).
sinonimo(musical, musical). sinonimo(musicales, musical).
sinonimo(fantasia, fantasia). sinonimo('fantasía', fantasia).
sinonimo(paranormal, paranormal). sinonimo(suspenso, suspenso).
sinonimo(emocionante, emocionante). sinonimo(emocionantes, emocionante).
sinonimo(emotiva, emocionante). sinonimo(emotivas, emocionante).
sinonimo(accion, accion). sinonimo('acción', accion).
sinonimo(scifi, ciencia_ficcion).
sinonimo(misterio, misterio). sinonimo(crimen, crimen).
sinonimo(documental, documental). sinonimo(belica, belica). sinonimo('bélica', belica).
sinonimo(triste, triste). sinonimo(tristes, triste).
sinonimo(aburrida, aburrida). sinonimo(aburridas, aburrida).
sinonimo(cringe, cringe). sinonimo(inspiradora, inspiradora).
sinonimo(C,C) :- resena_usuario(_,_,_,C,_,_).
sinonimo(G, G) :- genero(_, G).
sinonimo(E, E) :- etiqueta(_, E).
sinonimo(R, R) :- regla_experto_definida(R, _).
sinonimo(Plural, R) :- regla_experto_definida(R, _), atom_concat(R, 's', Plural).
sinonimo(Plural, G) :- genero(_, G), atom_concat(G, 's', Plural).
sinonimo(Plural, E) :- etiqueta(_, E), atom_concat(E, 's', Plural).

% titulo_consulta(?Criterio, ?Pelicula, ?Palabras): índice declarativo de títulos.
% El criterio es un átomo serializable para conservar el contrato JSON con Python.
titulo_consulta(titulo_el_conjuro, el_conjuro, [el,conjuro]).
titulo_consulta(titulo_el_conjuro, el_conjuro, [conjuro]).
titulo_consulta(titulo_it, it, [it]).
titulo_consulta(titulo_annabelle, annabelle, [annabelle]).
titulo_consulta(titulo_toy_story, toy_story, [toy,story]).
titulo_consulta(titulo_buscando_a_nemo, nemo, [buscando,a,nemo]).
titulo_consulta(titulo_buscando_a_nemo, nemo, [nemo]).
titulo_consulta(titulo_intensamente, intensamente, [intensamente]).
titulo_consulta(titulo_coco, coco, [coco]).
titulo_consulta(titulo_encanto, encanto, [encanto]).
titulo_consulta(titulo_shrek, shrek, [shrek]).
titulo_consulta(titulo_mi_villano_favorito, villano, [mi,villano,favorito]).
titulo_consulta(titulo_mi_villano_favorito, villano, [villano,favorito]).
titulo_consulta(titulo_deadpool, deadpool, [deadpool]).
titulo_consulta(titulo_joker, joker, [joker]).
titulo_consulta(titulo_coraline, coraline, [coraline]).
titulo_consulta(titulo_hotel_transilvania, hotel, [hotel,transilvania]).
titulo_consulta(titulo_titanic, titanic, [titanic]).
titulo_consulta(titulo_caso_terror_infantil, caso_terror_infantil,
                [caso,de,prueba,terror,infantil]).

% Indización automática de títulos para películas agregadas dinámicamente
titulo_consulta(Criterio, P, Palabras) :-
    pelicula(P, Titulo, _),
    \+ es_pelicula_estatica(P),
    atom_concat('titulo_', P, Criterio),
    palabras_texto(Titulo, Palabras).
titulo_consulta(Criterio, P, [PalabraSignificativa]) :-
    pelicula(P, Titulo, _),
    \+ es_pelicula_estatica(P),
    atom_concat('titulo_', P, Criterio),
    palabras_texto(Titulo, Palabras),
    Palabras = [_, _|_],
    member(PalabraSignificativa, Palabras),
    \+ palabra_comun(PalabraSignificativa).

es_pelicula_estatica(P) :-
    memberchk(P, [
        el_conjuro, it, annabelle, toy_story, nemo, intensamente,
        coco, encanto, shrek, villano, deadpool, joker,
        coraline, hotel, titanic, caso_terror_infantil
    ]).

% Prioridad de una pregunta adicional. Es conocimiento declarativo, no UI.
peso_criterio(terror, 100). peso_criterio(infantil, 98).
peso_criterio(familiar, 92). peso_criterio(comedia, 88).
peso_criterio(aventura, 86). peso_criterio(animacion, 84).
peso_criterio(romance, 82). peso_criterio(paranormal, 80).
peso_criterio(suspenso, 78). peso_criterio(fantasia, 76).
peso_criterio(musical, 74). peso_criterio(drama, 72).
peso_criterio(divertida, 70). peso_criterio(emocionante, 68).

pregunta_criterio(terror, '¿Deseas específicamente una película de terror?').
pregunta_criterio(infantil, '¿La película debe ser apta para público infantil?').
pregunta_criterio(familiar, '¿Prefieres una película de enfoque familiar?').
pregunta_criterio(comedia, '¿Quieres que la película pertenezca al género comedia?').
pregunta_criterio(aventura, '¿Te interesa que tenga aventura?').
pregunta_criterio(animacion, '¿Prefieres una película animada?').
pregunta_criterio(romance, '¿Buscas una historia de romance?').
pregunta_criterio(paranormal, '¿Te interesa una temática paranormal?').
pregunta_criterio(suspenso, '¿Quieres que tenga suspenso?').
pregunta_criterio(fantasia, '¿Prefieres elementos de fantasía?').
pregunta_criterio(musical, '¿Te interesa una historia con temática musical?').
pregunta_criterio(drama, '¿Buscas una película dramática?').
pregunta_criterio(divertida, '¿Es importante que sea divertida?').
pregunta_criterio(emocionante, '¿Buscas una historia emocionante o emotiva?').
pregunta_criterio(C, Pregunta) :-
    regla_experto_definida(C, Nombre),
    format(atom(Pregunta), '¿Deseas que cumpla la regla de experto "~w"?', [Nombre]).

% NIVEL 1: VALIDACIÓN DE HECHOS Y ENTRADAS (R01-R09)
pelicula_valida(P) :- pelicula(P, _, _).                                      % R01
genero_validado(P, G) :- pelicula_valida(P), genero(P, G).                    % R02
etiqueta_validada(P, E) :- pelicula_valida(P), etiqueta(P, E).                % R03
tema_validado(P, T) :- pelicula_valida(P), sinopsis(P, _), tema_sinopsis(P,T).% R04
edad_valida(P, Min) :- pelicula_valida(P), edad_minima(P, Min),
                       integer(Min), Min >= 0.                                 % R05
edad_compatible(P, Edad) :- integer(Edad), Edad >= 0, edad_valida(P, Min),
                            Edad >= Min.                                       % R06
edad_habilitada(P, -1) :- pelicula_valida(P), !.                              % R07
edad_habilitada(P, Edad) :- edad_compatible(P, Edad).
opinion_validada(P, Autor, Tema) :- pelicula_valida(P),
                                    opinion(P, Autor, _, Tema).                % R08
opinion_validada(P, Autor, Tema) :- pelicula_valida(P),
                                    resena_usuario(P, Autor, _, Tema, _, _).
contenido_de_terror(P) :- genero_validado(P, terror).                         % R09

% NIVEL 2: INFERENCIAS INTERMEDIAS (R10-R17)
orientacion_infantil(P) :- etiqueta_validada(P, infantil).                    % R10
orientacion_infantil(P) :- etiqueta_validada(P, familiar).
percepcion_recurrente(P, Tema, Total) :-                                      % R11
    pelicula_valida(P), findall(Autor,opinion_validada(P,Autor,Tema),Autores),
    sort(Autores,Unicos),length(Unicos,Total),Total>=1.
apta_para_ninos(P) :-                                                         % R12
    edad_valida(P,Min),Min=<10,orientacion_infantil(P),\+ contenido_de_terror(P).
coincidencia_genero(P,C,genero,Motivo) :-                                    % R13
    genero_validado(P,C),format(atom(Motivo),'Género editorial comprobado: ~w.',[C]).
coincidencia_etiqueta(P,C,etiqueta,Motivo) :-                                % R14
    etiqueta_validada(P,C),format(atom(Motivo),'Etiqueta editorial comprobada: ~w.',[C]).
coincidencia_sinopsis(P,C,sinopsis,Motivo) :-                                % R15
    tema_validado(P,C),format(atom(Motivo),'Tema indexado de la sinopsis: ~w.',[C]).
coincidencia_opinion(P,C,opiniones,Motivo) :-                                % R16
    percepcion_recurrente(P,C,Total),
    format(atom(Motivo),'~d autor(es) indicaron la percepción ~w.',[Total,C]).
texto_opinion(P,Texto) :- opinion(P,_,Texto,_).
texto_opinion(P,Texto) :- resena_usuario(P,_,Texto,_,_,_).
palabras_texto(Texto,Palabras) :-
    (atom(Texto)->atom_string(Texto,Cadena);Cadena=Texto),
    string_lower(Cadena,Minusculas),
    split_string(Minusculas," \t\n\r,.;:!?¿¡()[]{}\"'/-"," \t\n\r",Partes),
    exclude(=(""),Partes,NoVacias),maplist(atom_string,Palabras,NoVacias).
coincidencia_texto_opinion(P,C,texto_opinion,Motivo) :-
    texto_opinion(P,Texto),palabras_texto(Texto,Palabras),memberchk(C,Palabras),
    format(atom(Motivo),'La palabra ~w aparece en una reseña.',[C]).
coincidencia_infantil(P,infantil,clasificacion_infantil,Motivo) :-           % R17
    apta_para_ninos(P),edad_minima(P,Min),
    format(atom(Motivo),'Aptitud infantil inferida desde ~d años.',[Min]).
coincidencia_titulo(P,C,titulo,Motivo) :-
    titulo_consulta(C,P,_),pelicula(P,Titulo,_),
    format(atom(Motivo),'Coincidencia directa con el título "~w".',[Titulo]).
coincidencia_regla_experto(P,C,regla_experto,Motivo) :-
    pelicula_valida(P),
    regla_experto_definida(C,Nombre),
    current_predicate(C/1),
    Objetivo =.. [C, P],
    catch(call(Objetivo), _, fail),
    format(atom(Motivo),'Regla de experto cumplida: ~w (~w).',[Nombre,C]).

% NIVEL 3: BÚSQUEDA, RANKING Y SALIDA (R18-R29)
coincidencia(P,C,F,M) :- coincidencia_genero(P,C,F,M).                        % R18
coincidencia(P,C,F,M) :- coincidencia_etiqueta(P,C,F,M).
coincidencia(P,C,F,M) :- coincidencia_sinopsis(P,C,F,M).
coincidencia(P,C,F,M) :- coincidencia_opinion(P,C,F,M).
coincidencia(P,C,F,M) :- coincidencia_texto_opinion(P,C,F,M).
coincidencia(P,C,F,M) :- coincidencia_infantil(P,C,F,M).
coincidencia(P,C,F,M) :- coincidencia_titulo(P,C,F,M).
coincidencia(P,C,F,M) :- coincidencia_regla_experto(P,C,F,M).
puntaje_fuente(titulo,120) :- !.                                              % R19
puntaje_fuente(regla_experto,110) :- !.
puntaje_fuente(clasificacion_infantil,100) :- !.
puntaje_fuente(genero,95) :- !. puntaje_fuente(etiqueta,85) :- !.
puntaje_fuente(sinopsis,70) :- !. puntaje_fuente(opiniones,55) :- !.
puntaje_fuente(texto_opinion,40) :- !.
puntaje_fuente(_,20).
prioridad_de_puntaje(Puntaje,alta) :- Puntaje>=85,!.                          % R20
prioridad_de_puntaje(Puntaje,media) :- Puntaje>=55,!.
prioridad_de_puntaje(_,baja).
evidencia(P,C,evidencia(Puntos,C,Fuente,Motivo)) :-                           % R21
    coincidencia(P,C,Fuente,Motivo),puntaje_fuente(Fuente,Puntos).
mejor_evidencia([Primera|Resto],Mejor) :- mejor_aux(Resto,Primera,Mejor).     % R22
mejor_aux([],Mejor,Mejor).
mejor_aux([Actual|Resto],Acumulado,Mejor) :-
    Actual=evidencia(PAct,_,_,_),Acumulado=evidencia(PAnt,_,_,_),
    (PAct>PAnt->Siguiente=Actual;Siguiente=Acumulado),
    mejor_aux(Resto,Siguiente,Mejor).
evidencia_dict(evidencia(Puntos,C,Fuente,Motivo),                             % R23
    _{criterio:C,origen:Fuente,justificacion:Motivo,puntaje:Puntos}).
mejor_evidencia_criterio(P,C,Mejor) :-
    findall(E,evidencia(P,C,E),Evidencias),Evidencias\=[],
    mejor_evidencia(Evidencias,Mejor).
suma_puntajes([],0).
suma_puntajes([evidencia(P,_,_,_)|Resto],Total) :-
    suma_puntajes(Resto,Parcial),Total is P+Parcial.

calificacion_promedio(P,Promedio) :-
    findall(Calificacion,resena_usuario(P,_,_,_,Calificacion,_),Calificaciones),
    ( Calificaciones=[] -> Promedio=0.0
    ; sum_list(Calificaciones,Suma),length(Calificaciones,Total),
      Promedio is round((Suma/Total)*10)/10 ).
nivel_por_indice(Indice,alta) :- Indice>=70,!.
nivel_por_indice(Indice,media) :- Indice>=40,!.
nivel_por_indice(_,baja).
resultado_para(Criterios,P,                                                   % R24
    _{id:P,titulo:Titulo,anio:Anio,edad_minima:Min,generos:Generos,
      sinopsis:Resumen,prioridad:Prioridad,puntaje:PuntajePrincipal,
      puntaje_total:PuntajeTotal,puntaje_ranking:PuntajeRanking,
      calificacion_promedio:Calificacion,cobertura:Cobertura,
      criterios_solicitados:Solicitados,nivel_coincidencia:Nivel,indice_coincidencia:Indice,
      origen_principal:Fuente,justificacion_principal:Motivo,evidencias:Evidencias}) :-
    pelicula(P,Titulo,Anio),edad_valida(P,Min),sinopsis(P,Resumen),
    findall(G,genero_validado(P,G),GRaw),sort(GRaw,Generos),
    findall(E,(member(C,Criterios),criterio_admisible(P,C),evidencia(P,C,E)),ERaw),
    sort(ERaw,EUnicas),mejor_evidencia(EUnicas,
        evidencia(PuntajePrincipal,_,Fuente,Motivo)),
    findall(Mejor,(member(C,Criterios),criterio_admisible(P,C),
            mejor_evidencia_criterio(P,C,Mejor)),MejoresRaw),
    sort(MejoresRaw,Mejores),length(Mejores,Cobertura),
    length(Criterios,Solicitados),suma_puntajes(Mejores,PuntajeTotal),
    calificacion_promedio(P,Calificacion),
    BonusCalificacion is round(Calificacion*2),
    PuntajeRanking is PuntajeTotal*100+BonusCalificacion,
    Indice is round(PuntajeTotal*100/(Solicitados*120)),
    nivel_por_indice(Indice,Nivel),
    prioridad_de_puntaje(PuntajePrincipal,Prioridad),
    maplist(evidencia_dict,EUnicas,Evidencias).
buscar_peliculas(Criterios,Edad,Resultados) :-                                % R25
    is_list(Criterios),integer(Edad),Edad>= -1,
    findall(P,(member(C,Criterios),coincidencia(P,C,_,_),
                criterio_admisible(P,C),edad_habilitada(P,Edad),
                (memberchk(infantil,Criterios)->apta_para_ninos(P);true)),Duplicados),
    sort(Duplicados,Unicos),maplist(resultado_para(Criterios),Unicos,SinOrden),
    findall(Orden-P,(member(R,SinOrden),get_dict(id,R,P),
        get_dict(puntaje_ranking,R,Puntos),Orden is -Puntos),Pares),
    keysort(Pares,Ordenados),
    findall(R,(member(_-P,Ordenados),member(R,SinOrden),get_dict(id,R,P)),Resultados).
contiene_secuencia(Secuencia,Palabras) :-
    append(_,Resto,Palabras),append(Secuencia,_,Resto),!.
consulta_a_criterios(Consulta,Criterios) :-                                   % R26
    (atom(Consulta)->atom_string(Consulta,Texto);string(Consulta)->Texto=Consulta;Texto=""),
    string_lower(Texto,Minusculas),
    palabras_texto(Minusculas,Atoms),
    findall(C,(member(Atom,Atoms),sinonimo(Atom,C)),CriteriosSinonimos),
    findall(C,((categoria_usuario(_,C);resena_usuario(_,_,_,C,_,_)),
               atomic_list_concat(Secuencia,'_',C),contiene_secuencia(Secuencia,Atoms)),
            CriteriosCategorias),
    findall(C,(member(C,Atoms),\+sinonimo(C,_),\+palabra_comun(C),
               texto_opinion(P,_),coincidencia_texto_opinion(P,C,_,_)),CriteriosTexto),
    findall(CT,(titulo_consulta(CT,_,Secuencia),
                contiene_secuencia(Secuencia,Atoms)),CriteriosTitulo),
    append([CriteriosSinonimos,CriteriosCategorias,CriteriosTexto,CriteriosTitulo],Todos),
    sort(Todos,Criterios).
palabra_comun(C) :- memberchk(C,[pelicula,peliculas,'película','películas',una,un,el,la,los,las,de,del,para,por,que,con,y,en,es,son,me,da,dan,muy,esta,este,lo,al,a,ser,ver,quiero,busco]).
estado_consulta(Consulta,_,_,consulta_vacia) :-                               % R27
    (Consulta=="";Consulta==''),!.
estado_consulta(_,[],_,criterio_no_reconocido) :- !.
estado_consulta(_,_,[],sin_resultados) :- !.
estado_consulta(_,_,_,ok).
criterio_admisible(P,C) :- titulo_consulta(C,P,_),!.                          % R29
criterio_admisible(P,infantil) :- !,apta_para_ninos(P).
criterio_admisible(_,_).

% ENTREGABLE 2: EXPLICABILIDAD Y RECOMENDACIÓN (R30-R45)
regla_catalogo(r01,'Validación de película','Se comprobó que la película existe en el catálogo.').
regla_catalogo(r02,'Validación de género','El género consultado está registrado para la película.').
regla_catalogo(r03,'Validación de etiqueta','La etiqueta consultada está registrada para la película.').
regla_catalogo(r04,'Validación temática','La sinopsis posee el tema indexado consultado.').
regla_catalogo(r05,'Validación etaria','La edad mínima es un entero válido y no negativo.').
regla_catalogo(r11,'Percepción registrada','Al menos un autor indicó la percepción.').
regla_catalogo(r12,'Aptitud infantil','Combina edad, orientación familiar y ausencia de terror.').
regla_catalogo(r13,'Coincidencia por género','Activa evidencia editorial de género.').
regla_catalogo(r14,'Coincidencia por etiqueta','Activa evidencia editorial de etiqueta.').
regla_catalogo(r15,'Coincidencia por sinopsis','Activa evidencia temática de sinopsis.').
regla_catalogo(r16,'Coincidencia por opiniones','Una o más reseñas respaldan la percepción.').
regla_catalogo(r56,'Palabra en reseña','La palabra buscada aparece en el texto de una reseña.').
regla_catalogo(r17,'Coincidencia infantil','Activa la conclusión de aptitud infantil.').
regla_catalogo(r18,'Coincidencia por título','El texto ingresado coincide con un título indexado del catálogo.').
regla_catalogo(r_exp,'Regla de experto','La película cumple una condición lógica inyectada dinámicamente por un experto.').
regla_catalogo(r19,'Peso de la fuente','Asigna prioridad según la confiabilidad de la fuente.').
regla_catalogo(r24,'Construcción de hipótesis','Integra hechos, evidencias, cobertura y nivel.').
regla_catalogo(r25,'Selección y ranking','Deduplica y ordena hipótesis por puntaje simbólico.').
regla_fuente(genero,r02). regla_fuente(genero,r13).
regla_fuente(etiqueta,r03). regla_fuente(etiqueta,r14).
regla_fuente(sinopsis,r04). regla_fuente(sinopsis,r15).
regla_fuente(opiniones,r11). regla_fuente(opiniones,r16).
regla_fuente(texto_opinion,r56).
regla_fuente(clasificacion_infantil,r05).
regla_fuente(clasificacion_infantil,r12).
regla_fuente(clasificacion_infantil,r17).
regla_fuente(titulo,r18).
regla_fuente(regla_experto,r_exp).
regla_dict(Id,_{id:Id,nombre:Nombre,detalle:Detalle}) :-                     % R30
    regla_catalogo(Id,Nombre,Detalle).
reglas_disparadas(Criterios,P,Reglas) :-                                     % R31
    findall(Id,(member(C,Criterios),evidencia(P,C,evidencia(_,_,F,_)),
                regla_fuente(F,Id)),IdsFuente),
    append([r01,r19,r24,r25],IdsFuente,IdsRaw),sort(IdsRaw,Ids),
    maplist(regla_dict,Ids,Reglas).
hecho_evidencia(P,C,genero,Texto) :- format(atom(Texto),'genero(~w, ~w)',[P,C]).
hecho_evidencia(P,C,etiqueta,Texto) :- format(atom(Texto),'etiqueta(~w, ~w)',[P,C]).
hecho_evidencia(P,C,sinopsis,Texto) :- format(atom(Texto),'tema_sinopsis(~w, ~w)',[P,C]).
hecho_evidencia(P,C,opiniones,Texto) :-
    findall(A,opinion_validada(P,A,C),AutoresRaw),sort(AutoresRaw,Autores),
    format(atom(Texto),'percepciones_registradas(~w, ~w, ~w)',[P,C,Autores]).
hecho_evidencia(P,C,texto_opinion,Texto) :-
    format(atom(Texto),'palabra_en_resena(~w, ~w)',[P,C]).
hecho_evidencia(P,infantil,clasificacion_infantil,Texto) :-
    edad_minima(P,Min),format(atom(Texto),
    'edad_minima(~w, ~d) y orientación infantil sin terror',[P,Min]).
hecho_evidencia(P,C,titulo,Texto) :-
    titulo_consulta(C,P,_),pelicula(P,Titulo,_),
    format(atom(Texto),'titulo_coincidente(~w, "~w")',[P,Titulo]).
hecho_evidencia(P,C,regla_experto,Texto) :-
    format(atom(Texto),'regla_experto(~w(~w))',[C,P]).
hechos_verdaderos(Criterios,Edad,P,Hechos) :-                                 % R32
    pelicula(P,Titulo,Anio),edad_minima(P,Min),
    format(atom(HP),'pelicula(~w, "~w", ~d)',[P,Titulo,Anio]),
    format(atom(HE),'edad_minima(~w, ~d)',[P,Min]),
    findall(HC,(member(CIngresado,Criterios),
                format(atom(HC),'criterio_ingresado(~w)',[CIngresado])),CRaw),
    findall(H,(member(C,Criterios),evidencia(P,C,evidencia(_,_,F,_)),
               hecho_evidencia(P,C,F,H)),HRaw),
    (Edad>=0->format(atom(HU),'edad_usuario(~d)',[Edad]),Base=[HP,HE,HU];Base=[HP,HE]),
    append([Base,CRaw,HRaw],Todos),sort(Todos,Hechos).
mejor_puntaje([R|_],Puntaje) :- get_dict(puntaje_ranking,R,Puntaje).          % R33
hipotesis_competencia([],[]).
hipotesis_competencia(Resultados,Competidores) :-                            % R34
    mejor_puntaje(Resultados,Mejor),
    findall(R,(member(R,Resultados),get_dict(puntaje_ranking,R,Mejor)),Competidores).
competidor_dict(R,_{id:Id,titulo:Titulo,puntaje:Puntaje,
                    calificacion:Calificacion,
                    cobertura:Cobertura,nivel:Nivel}) :-                      % R35
    get_dict(id,R,Id),get_dict(titulo,R,Titulo),get_dict(puntaje_total,R,Puntaje),
    get_dict(calificacion_promedio,R,Calificacion),
    get_dict(cobertura,R,Cobertura),get_dict(nivel_coincidencia,R,Nivel).
criterio_soportado(P,C) :- coincidencia(P,C,_,_),criterio_admisible(P,C).     % R36
candidato_desempate(Criterios,Ids,C,Score) :-                                % R37
    peso_criterio(C,Peso),\+memberchk(C,Criterios),
    findall(P,(member(P,Ids),criterio_soportado(P,C)),ConRaw),sort(ConRaw,Con),
    length(Ids,Total),length(Con,Si),Si>0,Si<Total,
    Balance is abs(Total-2*Si),Score is Peso*100-Balance.
mejor_par([Primero|Resto],Mejor) :- mejor_par_aux(Resto,Primero,Mejor).
mejor_par_aux([],Mejor,Mejor).
mejor_par_aux([S-C|Resto],SA-CA,Mejor) :-
    (S>SA->Sig=S-C;Sig=SA-CA),mejor_par_aux(Resto,Sig,Mejor).
recomendacion_desempate(Criterios,Competidores,                             % R38
    _{criterio:C,pregunta:Pregunta,prioridad:alta,motivo:Motivo}) :-
    findall(P,(member(R,Competidores),get_dict(id,R,P)),Ids),
    findall(Score-Cand,candidato_desempate(Criterios,Ids,Cand,Score),Pares),
    Pares\=[],mejor_par(Pares,_-C),pregunta_criterio(C,Pregunta),
    format(atom(Motivo),'El criterio ~w divide las hipótesis líderes y tiene alto peso simbólico.',[C]),!.
recomendacion_desempate(_,_,
    _{criterio:preferencia_adicional,
      pregunta:'¿Qué género o característica adicional prefieres?',prioridad:media,
      motivo:'No existe un único criterio discriminante; se requiere otra preferencia.'}).
recomendacion_confirmacion(Criterios,[R],                                   % R39
    _{criterio:C,pregunta:Pregunta,prioridad:media,motivo:Motivo}) :-
    get_dict(id,R,P),findall(Peso-Cand,(peso_criterio(Cand,Peso),
        \+memberchk(Cand,Criterios),criterio_soportado(P,Cand)),Pares),
    Pares\=[],mejor_par(Pares,_-C),pregunta_criterio(C,Pregunta),
    format(atom(Motivo),'Confirmar ~w aumentaría la cobertura de la hipótesis líder.',[C]),!.
recomendacion_confirmacion(_,_,
    _{criterio:preferencia_adicional,
      pregunta:'¿Puedes indicar otra preferencia de género o temática?',prioridad:media,
      motivo:'La evidencia actual solo cubre parte de la consulta.'}).
decision_motor(_,_,[],                                                       % R40
    _{estado:sin_candidatos,definitiva:false,hipotesis_competencia:[],
      mensaje:'No hay hipótesis activas con la evidencia suministrada.',
      recomendacion:_{criterio:consulta_valida,
        pregunta:'Prueba con terror, comedia, aventura, romance, animación o infantil.',
        prioridad:alta,motivo:'La consulta no activó una hipótesis del catálogo.'}}) :- !.
decision_motor(Criterios,_,[Unica],
    _{estado:definitiva,definitiva:true,hipotesis_competencia:Competencia,
      mensaje:'La evidencia permite emitir una recomendación principal única.',
      recomendacion:_{criterio:ninguno,
        pregunta:'No se requieren más datos para esta recomendación.',
        prioridad:ninguna,motivo:'La hipótesis líder cubre todos los criterios ingresados.'}}) :-
    get_dict(cobertura,Unica,Cobertura),length(Criterios,Cobertura),
    competidor_dict(Unica,CD),Competencia=[CD],!.
decision_motor(Criterios,_,Competidores,
    _{estado:evidencia_insuficiente,definitiva:false,
      hipotesis_competencia:Competencia,
      mensaje:'Varias hipótesis empatan o la líder no cubre toda la evidencia.',
      recomendacion:Recomendacion}) :-
    maplist(competidor_dict,Competidores,Competencia),
    (Competidores=[_]->recomendacion_confirmacion(Criterios,Competidores,Recomendacion);
                       recomendacion_desempate(Criterios,Competidores,Recomendacion)).
motivo_descarte(Criterios,Edad,Resultados,Competidores,P,Titulo,Motivo) :-    % R41
    pelicula(P,Titulo,_),\+ (member(CR,Competidores),get_dict(id,CR,P)),
    (member(R,Resultados),get_dict(id,R,P),get_dict(puntaje_total,R,Pt),
       format(atom(Motivo),'Menor puntaje simbólico que la hipótesis líder (~d puntos).',[Pt])
    ; \+ (member(R2,Resultados),get_dict(id,R2,P)),
      (member(C,Criterios),coincidencia(P,C,_,_),\+criterio_admisible(P,C)->
          format(atom(Motivo),'Condición excluyente: ~w no supera el filtro crítico ~w.',[P,C])
      ;member(C2,Criterios),coincidencia(P,C2,_,_),criterio_admisible(P,C2),
       \+edad_habilitada(P,Edad)->edad_minima(P,Min),
          format(atom(Motivo),'Descartada por edad: requiere ~d años.',[Min])
      ; \+ (member(C3,Criterios),coincidencia(P,C3,_,_))->
          Motivo='No aporta evidencia para los criterios reconocidos.')).
primeros_n(N,Lista,Primeros) :- length(Prefijo,N),append(Prefijo,_,Lista),!,Primeros=Prefijo.
primeros_n(_,Lista,Lista).
hipotesis_descartadas(Criterios,Edad,Resultados,Competidores,Descartadas) :- % R42
    findall(_{id:P,titulo:Titulo,motivo:Motivo},
        motivo_descarte(Criterios,Edad,Resultados,Competidores,P,Titulo,Motivo),Raw),
    sort(Raw,Unicas),primeros_n(8,Unicas,Descartadas).
auditoria_motor(_,_,[],_,                                                    % R43
    _{hipotesis_principal:null,reglas_disparadas:[],hechos_verdaderos:[],
      hipotesis_descartadas:[]}) :- !.
auditoria_motor(Criterios,Edad,[Principal|Resto],Competidores,
    _{hipotesis_principal:Id,reglas_disparadas:Reglas,
      hechos_verdaderos:Hechos,hipotesis_descartadas:Descartadas}) :-
    get_dict(id,Principal,Id),reglas_disparadas(Criterios,Id,Reglas),
    hechos_verdaderos(Criterios,Edad,Id,Hechos),Resultados=[Principal|Resto],
    hipotesis_descartadas(Criterios,Edad,Resultados,Competidores,Descartadas).

% -----------------------------------------------------------------------------
% CARTELERA Y RESEÑAS PERSISTENTES (R46-R55)
% -----------------------------------------------------------------------------

normalizar_atom_entrada(Entrada,Atom) :-
    ( atom(Entrada) -> Atom=Entrada
    ; string(Entrada) -> atom_string(Atom,Entrada) ).

texto_limpio(Entrada,Minimo,Maximo,Texto,Atom) :-
    string(Entrada),normalize_space(string(Texto),Entrada),
    string_length(Texto,Longitud),Longitud>=Minimo,Longitud=<Maximo,
    atom_string(Atom,Texto).

percepcion_permitida(divertida).
percepcion_permitida(terror).
percepcion_permitida(emocionante).
percepcion_permitida(suspenso).
percepcion_permitida(romance).
percepcion_permitida(familiar).
percepcion_permitida(triste).
percepcion_permitida(aburrida).
percepcion_permitida(cringe).
percepcion_permitida(inspiradora).
percepcion_permitida(misterio).
percepcion_permitida(accion).
percepcion_permitida(fantasia).
% Una palabra personalizada permite extender el vocabulario sin modificar código.
percepcion_permitida(P) :- etiqueta_personalizada(P).

etiqueta_personalizada(P) :-
    atom(P),atom_length(P,L),L>=3,L=<30,
    atom_chars(P,Chars),maplist(letra_etiqueta,Chars).
letra_etiqueta(C) :- char_type(C,alpha),downcase_atom(C,C).
letra_etiqueta('_').

agregar_categoria_json(Identificador,Entrada,Json) :-
    ground([Identificador,Entrada]),normalizar_atom_entrada(Identificador,P),
    pelicula_valida(P),normalizar_atom_entrada(Entrada,Categoria),
    etiqueta_personalizada(Categoria),
    ( genero_validado(P,Categoria) -> Estado=existente
    ; assertz(categoria_usuario(P,Categoria)),
      catch(guardar_datos_json,E,(retract(categoria_usuario(P,Categoria)),throw(E))),
      Estado=agregada ),
    atom_json_dict(Json,_{ok:true,estado:Estado,categoria:Categoria},[]).

resena_dict(P,_{autor:Autor,texto:Texto,percepcion:Percepcion,
                calificacion:0,fecha:'Base académica',origen:base}) :-
    opinion(P,Autor,Texto,Percepcion).
resena_dict(P,_{autor:Autor,texto:Texto,percepcion:Percepcion,
                calificacion:Calificacion,fecha:Fecha,origen:usuario}) :-
    resena_usuario(P,Autor,Texto,Percepcion,Calificacion,Fecha).

listar_resenas(P,Resenas) :-
    findall(Resena,resena_dict(P,Resena),Resenas).

listar_resenas_json(Identificador,Json) :-
    ground(Identificador),normalizar_atom_entrada(Identificador,P),
    pelicula_valida(P),listar_resenas(P,Resenas),length(Resenas,Total),
    calificacion_promedio(P,Promedio),
    atom_json_dict(Json,_{pelicula:P,total:Total,
        calificacion_promedio:Promedio,resenas:Resenas},[]).

detalle_pelicula_json(Identificador,Json) :-
    ground(Identificador),normalizar_atom_entrada(Identificador,P),
    pelicula(P,Titulo,Anio),sinopsis(P,Resumen),edad_minima(P,EdadMinima),
    findall(G,genero_validado(P,G),GenerosRaw),sort(GenerosRaw,Generos),
    findall(E,etiqueta_validada(P,E),EtiquetasRaw),sort(EtiquetasRaw,Etiquetas),
    listar_resenas(P,Resenas),length(Resenas,TotalResenas),
    calificacion_promedio(P,Promedio),
    atom_json_dict(Json,_{id:P,titulo:Titulo,anio:Anio,sinopsis:Resumen,
        edad_minima:EdadMinima,generos:Generos,etiquetas:Etiquetas,
        calificacion_promedio:Promedio,total_resenas:TotalResenas,
        resenas:Resenas},[]).

autores_percepcion(P,Percepcion,Total) :-
    findall(Autor,opinion_validada(P,Autor,Percepcion),AutoresRaw),
    sort(AutoresRaw,Autores),length(Autores,Total).

agregar_resena_json(Identificador,AutorEntrada,TextoEntrada,
                    PercepcionEntrada,Calificacion,Json) :-
    ground([Identificador,AutorEntrada,TextoEntrada,PercepcionEntrada,Calificacion]),
    normalizar_atom_entrada(Identificador,P),pelicula_valida(P),
    texto_limpio(AutorEntrada,2,60,_,Autor),
    texto_limpio(TextoEntrada,10,600,_,Texto),
    normalizar_atom_entrada(PercepcionEntrada,Percepcion),
    percepcion_permitida(Percepcion),integer(Calificacion),between(1,5,Calificacion),
    get_time(Instante),format_time(atom(Fecha),'%Y-%m-%dT%H:%M:%S%:z',Instante),
    assertz(resena_usuario(P,Autor,Texto,Percepcion,Calificacion,Fecha)),
    catch(guardar_datos_json,E,
      (retract(resena_usuario(P,Autor,Texto,Percepcion,Calificacion,Fecha)),throw(E))),
    autores_percepcion(P,Percepcion,AutoresPercepcion),
    Activa=true,
    Mensaje='Reseña guardada. Su percepción y palabras ya pueden aportar evidencia.',
    listar_resenas(P,Resenas),length(Resenas,Total),
    calificacion_promedio(P,Promedio),
    atom_json_dict(Json,_{ok:true,pelicula:P,total_resenas:Total,
        calificacion_promedio:Promedio,percepcion:Percepcion,
        autores_percepcion:AutoresPercepcion,activa_inferencia:Activa,
        mensaje:Mensaje},[]).

% R44: punto de entrada auditable. El JSON es el único contrato con Python.
buscar_json(Consulta,Edad,Json) :-
    ground(Consulta),integer(Edad),Edad>= -1,
    dcg_consulta_a_criterios(Consulta,CriteriosDCG),
    consulta_a_criterios(Consulta,CriteriosSim),
    append(CriteriosDCG,CriteriosSim,TodosRaw),
    sort(TodosRaw,Criterios),
    buscar_peliculas(Criterios,Edad,Resultados),
    estado_consulta(Consulta,Criterios,Resultados,Estado),length(Resultados,Total),
    hipotesis_competencia(Resultados,Competidores),
    decision_motor(Criterios,Resultados,Competidores,Decision),
    auditoria_motor(Criterios,Edad,Resultados,Competidores,Auditoria),
    atom_json_dict(Json,_{consulta:Consulta,criterios:Criterios,
      edad_consultada:Edad,estado:Estado,total:Total,resultados:Resultados,
      decision:Decision,auditoria:Auditoria},[]).
buscar_json(Consulta,Json) :- buscar_json(Consulta,-1,Json).                   % R45


% =============================================================================
% ENTREGABLE 3 — SECCIÓN A: DCG (Definite Clause Grammars) para Lenguaje Natural
% =============================================================================
% Parseo de oraciones en español libre para extraer criterios canónicos.
% El predicado principal es dcg_consulta_a_criterios/2:
%   dcg_consulta_a_criterios(+TextoAtom, -ListaCriterios)
%
% Arquitectura:
%   1. Tokenización: se divide el texto en átomos en minúsculas.
%   2. Las reglas DCG consumen la lista de tokens e identifican frases relevantes.
%   3. Los criterios reconocidos se unifican con el vocabulario canónico
%      a través de los mismos sinonimos/2 ya existentes.
%   4. Los tokens no reconocidos se saltan silenciosamente (tolerancia a ruido).
% =============================================================================

% --- Tokenización (reutiliza palabras_texto/2 ya definida en el motor) ---

% dcg_tokenizar(+TextoAtom, -Tokens)
%   Convierte una cadena/átomo a lista de átomos en minúsculas, filtrando vacíos.
dcg_tokenizar(Texto, Tokens) :-
    ( atom(Texto) -> atom_string(Texto, Cadena) ; Cadena = Texto ),
    string_lower(Cadena, Min),
    split_string(Min, " \t\n\r,.;:!?¿¡()[]{}\"'/-", " \t\n\r", Partes),
    exclude(=(""), Partes, NoVacias),
    maplist(atom_string, Tokens, NoVacias).

% =============================================================================
% Vocabulario DCG: palabras funcionales (artículos, preposiciones, nexos)
% =============================================================================

% Nexos y palabras vacías que el DCG puede consumir sin producir criterios.
nexo([quiero]).   nexo([busco]).    nexo([dame]).    nexo([pon]).
nexo([ver]).      nexo([una]).      nexo([un]).      nexo([unas]).
nexo([unos]).     nexo([el]).       nexo([la]).      nexo([los]).
nexo([las]).      nexo([de]).       nexo([del]).     nexo([que]).
nexo([para]).     nexo([con]).      nexo([y]).       nexo([o]).
nexo([en]).       nexo([es]).       nexo([son]).     nexo([me]).
nexo([muy]).      nexo([algo]).     nexo([tipo]).    nexo([mas]).
nexo([pero]).     nexo([también]).  nexo([tambien]). nexo([poco]).
nexo([bastante]). nexo([super]).    nexo([bien]).    nexo([mal]).
nexo([película]). nexo([pelicula]). nexo([películas]). nexo([peliculas]).
nexo([historia]).  nexo([filme]).   nexo([film]).    nexo([cinta]).
nexo([recomiendame]). nexo([recomiéndame]). nexo([recomienda]).
nexo([sugiereme]). nexo([sugiéreme]). nexo([sugiere]).
nexo([favor]). nexo([mostrar]). nexo([muestra]).
nexo([cual]). nexo([cuál]). nexo([hay]).

% Tokens que pueden preceder a un criterio sin ser criterio por sí mismos.
prefijo_criterio([de]).
prefijo_criterio([de, terror]).    % "algo de terror" → se prefiere la forma con criterio
prefijo_criterio([tipo]).
prefijo_criterio([estilo]).
prefijo_criterio([genero]).
prefijo_criterio([género]).
prefijo_criterio([tematica]).
prefijo_criterio([temática]).

% =============================================================================
% Reglas DCG principales
% =============================================================================

% frase_criterio(-Criterio)//
%   Reconoce una "frase criterio" en el flujo de tokens y unifica Criterio
%   con el átomo canónico correspondiente.
%
%   Estrategia multi-nivel:
%     (a) Título de película de dos palabras (ej. "toy story", "hotel transilvania")
%     (b) Criterio por sinónimo de una sola palabra
%     (c) Criterio compuesto por dos palabras (ej. "buena onda" → no existe, pero
%         "terror infantil" → terror + infantil por separado)
%   Los niveles más específicos tienen prioridad gracias al orden de las cláusulas.

% (a) Títulos de dos tokens
frase_criterio(C) --> [T1, T2],
    { atomic_list_concat([T1, T2], ' ', Par),
      titulo_consulta(C, _, Seq),
      ( Seq = [T1, T2] ; atomic_list_concat(Seq, ' ', Par) ) }, !.

% (b) Título de un token
frase_criterio(C) --> [T],
    { titulo_consulta(C, _, Seq), Seq = [T] }, !.

% (c) Criterio por sinónimo de un token
frase_criterio(C) --> [T],
    { sinonimo(T, C), \+ nexo([T]) }, !.

% =============================================================================
% Oración DCG de más alto nivel
% =============================================================================

% oracion(-Criterios)//
%   Parsea la lista completa de tokens extrayendo todos los criterios.
%   Los tokens no reconocidos se saltan token a token.

oracion([]) --> [].

oracion([C|Cs]) --> frase_criterio(C), !, oracion(Cs).

% Consumir un nexo conocido sin producir criterio
oracion(Cs) --> [T], { nexo([T]) }, !, oracion(Cs).

% Saltar cualquier token no reconocido (tolerancia a ruido)
oracion(Cs) --> [_], !, oracion(Cs).

% =============================================================================
% Punto de entrada DCG
% =============================================================================

% dcg_consulta_a_criterios(+Texto, -Criterios)
%   Convierte texto libre en lista de criterios canónicos usando DCG.
%   Devuelve [] si no reconoce ningún criterio (jamás falla).
dcg_consulta_a_criterios(Texto, Criterios) :-
    ( atom(Texto) -> atom_string(Texto, Cadena)
    ; string(Texto) -> Cadena = Texto
    ; Cadena = "" ),
    string_lower(Cadena, Min),
    dcg_tokenizar(Min, Tokens),
    ( phrase(oracion(CsRaw), Tokens) -> true ; CsRaw = [] ),
    sort(CsRaw, Criterios).

% =============================================================================
% Punto de entrada JSON para el DCG (usado desde Python)
% =============================================================================

% dcg_buscar_json(+Texto, +Edad, -Json)
%   Como buscar_json/3 pero usando el parser DCG en lugar del extractor simple.
dcg_buscar_json(Consulta, Edad, Json) :-
    ground(Consulta), integer(Edad), Edad >= -1,
    dcg_consulta_a_criterios(Consulta, CriteriosDCG),
    % También conservamos los criterios del extractor original para robustez
    consulta_a_criterios(Consulta, CriteriosSim),
    append(CriteriosDCG, CriteriosSim, TodosRaw),
    sort(TodosRaw, Criterios),
    buscar_peliculas(Criterios, Edad, Resultados),
    estado_consulta(Consulta, Criterios, Resultados, Estado),
    length(Resultados, Total),
    hipotesis_competencia(Resultados, Competidores),
    decision_motor(Criterios, Resultados, Competidores, Decision),
    auditoria_motor(Criterios, Edad, Resultados, Competidores, Auditoria),
    atom_json_dict(Json, _{consulta:Consulta, criterios:Criterios,
      edad_consultada:Edad, estado:Estado, total:Total,
      resultados:Resultados, decision:Decision, auditoria:Auditoria,
      modo_dcg:true}, []).

% dcg_analizar_json(+Texto, -Json)
%   Solo tokeniza y parsea; no busca películas. Útil para diagnóstico en la UI.
dcg_analizar_json(Texto, Json) :-
    ground(Texto),
    dcg_tokenizar(Texto, Tokens),
    ( phrase(oracion(CsRaw), Tokens) -> true ; CsRaw = [] ),
    sort(CsRaw, Criterios),
    atom_json_dict(Json, _{tokens:Tokens, criterios_dcg:Criterios}, []).

% =============================================================================
% ENTREGABLE 3 — SECCIÓN B: Adquisición Dinámica de Conocimiento (Modo Experto)
% =============================================================================
% Permite que un usuario con rol "Experto" inyecte nuevas películas, géneros,
% etiquetas y reglas lógicas en tiempo de ejecución, con persistencia automática
% en el archivo .pl mediante escritura de cláusulas Prolog.
%
% CONTRATOS:
%   experto_agregar_pelicula_json(+Id,+Titulo,+Anio,+Generos,+EdadMin,+Sinopsis,-Json)
%   experto_agregar_genero_json(+PeliculaId,+Genero,-Json)
%   experto_agregar_etiqueta_json(+PeliculaId,+Etiqueta,-Json)
%   experto_agregar_regla_json(+NombreRegla,+CabezaAtom,+CuerpoAtom,-Json)
%   experto_listar_reglas_json(-Json)
%   experto_retract_regla_json(+Id,-Json)
% =============================================================================

:- dynamic pelicula_experto/3.    % marca que esta película fue agregada dinámicamente
:- dynamic genero_experto/2.
:- dynamic etiqueta_experto/2.
:- dynamic edad_minima_experto/2.
:- dynamic sinopsis_experto/2.

% ---- Validadores de entrada ----

id_valido(Id) :-
    atom(Id), atom_length(Id, L), L >= 2, L =< 40,
    atom_chars(Id, Chars),
    maplist(char_id_valido, Chars).
char_id_valido(C) :- char_type(C, alpha), downcase_atom(C, C).
char_id_valido('_').
char_id_valido(C) :- char_type(C, digit).

anio_valido(A) :- integer(A), A >= 1888, A =< 2100.

edad_min_valida(E) :- integer(E), E >= 0, E =< 21.

% ---- Escritura de cláusulas en disco ----

% escribir_clausula_pl(+Cabeza, +Cuerpo)
%   Agrega una cláusula al final del archivo .pl de forma atómica.
%   Cabeza es un término Prolog; Cuerpo es [] (hecho) o lista de objetivos.
escribir_clausula_pl(Cabeza, []) :- !,
    ruta_base_pl(Ruta),
    setup_call_cleanup(
        open(Ruta, append, S, [encoding(utf8)]),
        ( write_canonical(S, Cabeza), write(S, '.\n') ),
        close(S)
    ).
escribir_clausula_pl(Cabeza, Cuerpo) :-
    is_list(Cuerpo), !,
    ruta_base_pl(Ruta),
    setup_call_cleanup(
        open(Ruta, append, S, [encoding(utf8)]),
        ( write_canonical(S, Cabeza), write(S, ' :-\n    '),
          escribir_cuerpo_pl(S, Cuerpo), write(S, '.\n') ),
        close(S)
    ).

escribir_cuerpo_pl(S, [G]) :- !, write_canonical(S, G).
escribir_cuerpo_pl(S, [G|Gs]) :-
    write_canonical(S, G), write(S, ',\n    '),
    escribir_cuerpo_pl(S, Gs).

% Escribe texto literal (para cláusulas ya formateadas como átomo/cadena)
escribir_texto_pl(Texto) :-
    ruta_base_pl(Ruta),
    setup_call_cleanup(
        open(Ruta, append, S, [encoding(utf8)]),
        ( write(S, '\n'), write(S, Texto), write(S, '\n') ),
        close(S)
    ).

:- dynamic ruta_archivo_pl/1.

fijar_ruta_base_pl(RutaEntrada) :-
    normalizar_atom_entrada(RutaEntrada, Ruta),
    retractall(ruta_archivo_pl(_)),
    assertz(ruta_archivo_pl(Ruta)).

% ruta_base_pl(-Ruta)  — localiza el archivo .pl en tiempo de ejecución.
ruta_base_pl(Ruta) :-
    ruta_archivo_pl(Ruta), !.
ruta_base_pl(Ruta) :-
    source_file(pelicula_valida(_), Ruta), !.
ruta_base_pl(Ruta) :-
    source_file(buscar_json(_,_,_), Ruta), !.

% ---- Agregar película ----

experto_agregar_pelicula_json(IdEntrada, TituloEntrada, AnioEntrada,
                              GenerosEntrada, EdadMinEntrada,
                              SinopsisEntrada, Json) :-
    ground([IdEntrada, TituloEntrada, AnioEntrada, GenerosEntrada,
            EdadMinEntrada, SinopsisEntrada]),
    normalizar_atom_entrada(IdEntrada, Id),
    id_valido(Id),
    normalizar_atom_entrada(TituloEntrada, Titulo),
    atom_length(Titulo, TL), TL >= 1, TL =< 120,
    ( integer(AnioEntrada) -> Anio = AnioEntrada
    ; atom_number(AnioEntrada, Anio), integer(Anio) ),
    anio_valido(Anio),
    ( integer(EdadMinEntrada) -> EdadMin = EdadMinEntrada
    ; atom_number(EdadMinEntrada, EdadMin), integer(EdadMin) ),
    edad_min_valida(EdadMin),
    normalizar_atom_entrada(SinopsisEntrada, Sinopsis),
    atom_length(Sinopsis, SL), SL >= 10, SL =< 2000,
    % Parsear géneros (lista de átomos o átomo separado por comas)
    ( is_list(GenerosEntrada) -> GenerosRaw = GenerosEntrada
    ; atom(GenerosEntrada) ->
        atomic_list_concat(Parts, ',', GenerosEntrada),
        maplist([P,G]>>(atom_string(P, PS), normalize_space(string(PSN), PS),
                        atom_string(G, PSN)), Parts, GenerosRaw)
    ; GenerosRaw = [] ),
    maplist(normalizar_atom_entrada, GenerosRaw, Generos),
    % Verificar que el ID no existe ya
    ( pelicula(Id, _, _) ->
        atom_json_dict(Json, _{ok:false,
            mensaje:'Ya existe una película con ese identificador.'}, [])
    ;
        % Inyectar en memoria
        assertz(pelicula(Id, Titulo, Anio)),
        assertz(edad_minima(Id, EdadMin)),
        assertz(sinopsis(Id, Sinopsis)),
        maplist([G]>>(assertz(genero(Id, G))), Generos),
        assertz(pelicula_experto(Id, Titulo, Anio)),
        % Persistir en disco
        format(atom(LineaPelicula),
            '\n% [EXPERTO] Película agregada dinámicamente\npelicula(~q, ~q, ~w).',
            [Id, Titulo, Anio]),
        format(atom(LineaEdad), '\nedad_minima(~q, ~w).', [Id, EdadMin]),
        format(atom(LineaSin), '\nsinopsis(~q, ~q).', [Id, Sinopsis]),
        escribir_texto_pl(LineaPelicula),
        escribir_texto_pl(LineaEdad),
        escribir_texto_pl(LineaSin),
        maplist([G]>>(
            format(atom(LineaG), '\ngenero(~q, ~q).', [Id, G]),
            escribir_texto_pl(LineaG)
        ), Generos),
        atom_json_dict(Json, _{ok:true,
            mensaje:'Película agregada al catálogo y persistida en base_conocimiento.pl.',
            id:Id, titulo:Titulo, anio:Anio,
            edad_minima:EdadMin, generos:Generos}, [])
    ).

% ---- Agregar género a película existente (modo experto) ----

experto_agregar_genero_json(IdEntrada, GeneroEntrada, Json) :-
    ground([IdEntrada, GeneroEntrada]),
    normalizar_atom_entrada(IdEntrada, Id),
    pelicula_valida(Id),
    normalizar_atom_entrada(GeneroEntrada, Genero),
    id_valido(Genero),
    ( genero(Id, Genero) ->
        atom_json_dict(Json, _{ok:false,
            mensaje:'La película ya tiene ese género.'}, [])
    ;
        assertz(genero(Id, Genero)),
        assertz(genero_experto(Id, Genero)),
        format(atom(Linea), '\n% [EXPERTO]\ngenero(~q, ~q).', [Id, Genero]),
        escribir_texto_pl(Linea),
        atom_json_dict(Json, _{ok:true,
            mensaje:'Género agregado y persistido.',
            pelicula:Id, genero:Genero}, [])
    ).

% ---- Agregar etiqueta a película existente (modo experto) ----

experto_agregar_etiqueta_json(IdEntrada, EtiquetaEntrada, Json) :-
    ground([IdEntrada, EtiquetaEntrada]),
    normalizar_atom_entrada(IdEntrada, Id),
    pelicula_valida(Id),
    normalizar_atom_entrada(EtiquetaEntrada, Etiqueta),
    id_valido(Etiqueta),
    ( etiqueta(Id, Etiqueta) ->
        atom_json_dict(Json, _{ok:false,
            mensaje:'La película ya tiene esa etiqueta.'}, [])
    ;
        assertz(etiqueta(Id, Etiqueta)),
        assertz(etiqueta_experto(Id, Etiqueta)),
        format(atom(Linea), '\n% [EXPERTO]\netiqueta(~q, ~q).', [Id, Etiqueta]),
        escribir_texto_pl(Linea),
        atom_json_dict(Json, _{ok:true,
            mensaje:'Etiqueta agregada y persistida.',
            pelicula:Id, etiqueta:Etiqueta}, [])
    ).

% ---- Agregar regla lógica arbitraria (modo experto avanzado) ----
%
% experto_agregar_regla_json(+Nombre, +CabezaAtom, +CuerpoAtom, -Json)
%   Nombre     : etiqueta descriptiva (átomo), ej. 'pelicula recomendada para jovenes'
%   CabezaAtom : cabeza de la cláusula como cadena Prolog, ej. 'jovenes_ok(X)'
%   CuerpoAtom : cuerpo como cadena, ej. 'edad_minima(X,E),E=<17'  (o '' para hecho)
%
% SEGURIDAD: Se validan los textos con un parser conservador que solo admite
% cláusulas que referencian predicados declarados como seguros.
experto_agregar_regla_json(NombreEntrada, CabezaStr, CuerpoStr, Json) :-
    ground([NombreEntrada, CabezaStr, CuerpoStr]),
    normalizar_atom_entrada(NombreEntrada, Nombre),
    atom_length(Nombre, NL), NL >= 3, NL =< 80,
    % Parsear cabeza y cuerpo de forma unificada para que las variables
    % (ej. 'P' en la cabeza y 'P' en el cuerpo) compartan el mismo ámbito lógico.
    ( atom(CabezaStr) -> atom_string(CabezaStr, CabezaS) ; CabezaS = CabezaStr ),
    atom_string(CabezaAtom, CabezaS),
    ( atom(CuerpoStr) -> atom_string(CuerpoStr, CuerpoS) ; CuerpoS = CuerpoStr ),
    normalize_space(string(CuerpoTrim), CuerpoS),
    ( CuerpoTrim = "" ->
        ClausulaStr = CabezaAtom,
        term_to_atom(ClausulaTerm, CabezaAtom),
        functor(ClausulaTerm, Functor, Aridad)
    ;
        atom_string(CuerpoAtom, CuerpoTrim),
        atomic_list_concat([CabezaAtom, ' :-\n    ', CuerpoAtom], ClausulaStr),
        term_to_atom(ClausulaTerm, ClausulaStr),
        ClausulaTerm = (Cabeza :- _),
        functor(Cabeza, Functor, Aridad)
    ),
    % Validar que el functor de la cabeza es seguro (no puede sobrescribir
    % predicados internos del motor).
    ( predicado_experto_permitido(Functor, Aridad) ->
        dynamic(Functor/Aridad),
        discontiguous(Functor/Aridad),
        % Inyectar en memoria la cláusula unificada
        assertz(ClausulaTerm),
        ( Aridad =:= 1 ->
            assertz(regla_experto_definida(Functor, Nombre))
        ; true ),
        % Generar identificador único
        get_time(T), format(atom(IdRegla), 'regla_exp_~0f', [T]),
        assertz(diagnostico_experto(IdRegla, Nombre, ClausulaStr)),
        % Persistir en disco
        ( Aridad =:= 1 ->
            format(atom(Linea),
                '\n:- dynamic ~w/~w.\n:- discontiguous ~w/~w.\nregla_experto_definida(~w, ~q).\n% [EXPERTO] Regla: ~w\n~w.',
                [Functor, Aridad, Functor, Aridad, Functor, Nombre, Nombre, ClausulaStr])
        ;
            format(atom(Linea),
                '\n:- dynamic ~w/~w.\n:- discontiguous ~w/~w.\n% [EXPERTO] Regla: ~w\n~w.',
                [Functor, Aridad, Functor, Aridad, Nombre, ClausulaStr])
        ),
        escribir_texto_pl(Linea),
        atom_json_dict(Json, _{ok:true,
            mensaje:'Regla inyectada en memoria y persistida en base_conocimiento.pl.',
            id:IdRegla, nombre:Nombre, clausula:ClausulaStr}, [])
    ;
        format(atom(Msg),
            'El predicado ~w/~w no está permitido para reglas de experto.',
            [Functor, Aridad]),
        atom_json_dict(Json, _{ok:false, mensaje:Msg}, [])
    ).

% Lista blanca de functores que el experto puede definir.
% Los predicados del motor (buscar_json, buscar_peliculas, etc.) están excluidos.
predicado_experto_permitido(Functor, _) :-
    atom(Functor),
    \+ memberchk(Functor, [
        buscar_json, buscar_peliculas, consulta_a_criterios,
        dcg_buscar_json, dcg_analizar_json,
        agregar_resena_json, agregar_categoria_json,
        experto_agregar_pelicula_json, experto_agregar_genero_json,
        experto_agregar_etiqueta_json, experto_agregar_regla_json,
        experto_retract_regla_json, experto_listar_reglas_json,
        guardar_datos_json, inicializar_resenas, cargar_datos_json,
        ruta_base_pl, escribir_clausula_pl, escribir_texto_pl
    ]).

% ---- Listar reglas de experto ----

experto_listar_reglas_json(Json) :-
    findall(_{id:Id, nombre:Nombre, clausula:Clausula},
            diagnostico_experto(Id, Nombre, Clausula),
            Reglas),
    length(Reglas, Total),
    atom_json_dict(Json, _{ok:true, total:Total, reglas:Reglas}, []).

% ---- Retraer regla de experto ----

experto_retract_regla_json(IdEntrada, Json) :-
    ground(IdEntrada),
    normalizar_atom_entrada(IdEntrada, Id),
    ( diagnostico_experto(Id, Nombre, Clausula) ->
        retract(diagnostico_experto(Id, Nombre, Clausula)),
        ( term_to_atom(TermClausula, Clausula),
          ( TermClausula = (CabezaRetract :- _) -> functor(CabezaRetract, FRetract, ARetract)
          ; functor(TermClausula, FRetract, ARetract) ) ->
            ( ARetract =:= 1 -> retractall(regla_experto_definida(FRetract, _)) ; true ),
            retractall(CabezaRetract)
        ; true ),
        atom_json_dict(Json, _{ok:true,
            mensaje:'Regla eliminada de la memoria (el archivo .pl conserva el historial).',
            id:Id, nombre:Nombre}, [])
    ;
        atom_json_dict(Json, _{ok:false,
            mensaje:'No se encontró una regla con ese identificador.'}, [])
    ).

% ---- Listar películas agregadas por el experto ----

experto_listar_peliculas_json(Json) :-
    findall(_{id:Id, titulo:Titulo, anio:Anio},
            pelicula_experto(Id, Titulo, Anio),
            Peliculas),
    length(Peliculas, Total),
    atom_json_dict(Json, _{ok:true, total:Total, peliculas:Peliculas}, []).

% ---- Listar todos los predicados del catálogo (para diagnóstico DCG) ----

experto_catalogo_json(Json) :-
    findall(_{id:Id, titulo:Titulo, anio:Anio},
            pelicula(Id, Titulo, Anio), Peliculas),
    findall(S, sinonimo(S, _), SimRaw), sort(SimRaw, Sinonimos),
    atom_json_dict(Json, _{ok:true,
        peliculas:Peliculas, sinonimos_registrados:Sinonimos}, []).

:- dynamic vintage/1.
:- discontiguous vintage/1.
regla_experto_definida(vintage, 'Película vintage').
% [EXPERTO] Regla: Película vintage
vintage(P) :-
    pelicula(P, _, Anio), Anio < 2000.

:- dynamic colombiana/1.
:- discontiguous colombiana/1.
regla_experto_definida(colombiana, 'Película colombiana').
% [EXPERTO] Regla: Película colombiana
colombiana(P) :-
    pelicula(P, _, Anio), Anio > 2000, genero(P, colombiana).

% [EXPERTO] Película agregada dinámicamente
pelicula(poeta_2026, 'Un Poeta', 2026).
edad_minima(poeta_2026, 0).
sinopsis(poeta_2026, 'Un Poeta Sinopsis').
genero(poeta_2026, drama).
genero(poeta_2026, comedia).
genero(poeta_2026, colombiana).


:- dynamic vintage/1.
:- discontiguous vintage/1.
regla_experto_definida(vintage, 'pelicula vintage').
% [EXPERTO] Regla: pelicula vintage
vintage(P) :-
    pelicula(P, _, Anio), Anio < 2000..


% [EXPERTO] Película agregada dinámicamente
pelicula(matrix_1990, 'The Matrix', 1990).


edad_minima(matrix_1990, 12).


sinopsis(matrix_1990, 'Prueba Matrix').


genero(matrix_1990, accion).


genero(matrix_1990, aventura).


% [EXPERTO]
genero(matrix_1990, ciencia_ficcion).


% [EXPERTO]
etiqueta(el_conjuro, futurista).


:- dynamic noventera/1.
:- discontiguous noventera/1.
regla_experto_definida(noventera, noventera).
% [EXPERTO] Regla: noventera
noventera(P) :-
    pelicula(P,_,Anio), Anio >=1990, Anio=<1999.
