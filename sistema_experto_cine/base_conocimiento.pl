/* CineExperto - motor simbólico y explicable del Entregable 2.
   Edades y reseñas: datos DIDÁCTICOS, NO clasificaciones oficiales.
   Python solo captura/presenta datos; inferencia, traza y desempate viven aquí.
*/
:- encoding(utf8).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(persistency)).

% Las reseñas creadas desde la interfaz viven en un almacén Prolog separado.
% La ruta se adjunta desde Python para no depender del directorio de ejecución.
:- persistent
    resena_usuario(pelicula:atom, autor:atom, texto:atom,
                   percepcion:atom, calificacion:integer, fecha:atom).

inicializar_resenas(Archivo) :- db_attach(Archivo, []).

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
sinonimo(animadas, animacion). sinonimo(comedia, comedia).
sinonimo(aventura, aventura). sinonimo(aventuras, aventura).
sinonimo(drama, drama). sinonimo(romance, romance).
sinonimo(romantica, romance). sinonimo('romántica', romance).
sinonimo(musical, musical). sinonimo(musicales, musical).
sinonimo(fantasia, fantasia). sinonimo('fantasía', fantasia).
sinonimo(paranormal, paranormal). sinonimo(suspenso, suspenso).
sinonimo(emocionante, emocionante). sinonimo(emocionantes, emocionante).
sinonimo(emotiva, emocionante). sinonimo(emotivas, emocionante).

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
    sort(Autores,Unicos),length(Unicos,Total),Total>=2.
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
    format(atom(Motivo),'~d autores independientes coincidieron en ~w.',[Total,C]).
coincidencia_infantil(P,infantil,clasificacion_infantil,Motivo) :-           % R17
    apta_para_ninos(P),edad_minima(P,Min),
    format(atom(Motivo),'Aptitud infantil inferida desde ~d años.',[Min]).
coincidencia_titulo(P,C,titulo,Motivo) :-
    titulo_consulta(C,P,_),pelicula(P,Titulo,_),
    format(atom(Motivo),'Coincidencia directa con el título "~w".',[Titulo]).

% NIVEL 3: BÚSQUEDA, RANKING Y SALIDA (R18-R29)
coincidencia(P,C,F,M) :- coincidencia_genero(P,C,F,M).                        % R18
coincidencia(P,C,F,M) :- coincidencia_etiqueta(P,C,F,M).
coincidencia(P,C,F,M) :- coincidencia_sinopsis(P,C,F,M).
coincidencia(P,C,F,M) :- coincidencia_opinion(P,C,F,M).
coincidencia(P,C,F,M) :- coincidencia_infantil(P,C,F,M).
coincidencia(P,C,F,M) :- coincidencia_titulo(P,C,F,M).
puntaje_fuente(titulo,120) :- !.                                              % R19
puntaje_fuente(clasificacion_infantil,100) :- !.
puntaje_fuente(genero,95) :- !. puntaje_fuente(etiqueta,85) :- !.
puntaje_fuente(sinopsis,70) :- !. puntaje_fuente(opiniones,55) :- !.
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
nivel_coincidencia(Solicitados,Cobertura,muy_alta) :-
    Solicitados>=2,Cobertura=:=Solicitados,!.
nivel_coincidencia(Solicitados,Cobertura,alta) :-
    Solicitados>=1,Cobertura=:=Solicitados,!.
nivel_coincidencia(_,Cobertura,parcial) :- Cobertura>0,!.
nivel_coincidencia(_,_,insuficiente).
resultado_para(Criterios,P,                                                   % R24
    _{id:P,titulo:Titulo,anio:Anio,edad_minima:Min,generos:Generos,
      sinopsis:Resumen,prioridad:Prioridad,puntaje:PuntajePrincipal,
      puntaje_total:PuntajeTotal,puntaje_ranking:PuntajeRanking,
      calificacion_promedio:Calificacion,cobertura:Cobertura,
      criterios_solicitados:Solicitados,nivel_coincidencia:Nivel,
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
    nivel_coincidencia(Solicitados,Cobertura,Nivel),
    prioridad_de_puntaje(PuntajePrincipal,Prioridad),
    maplist(evidencia_dict,EUnicas,Evidencias).
buscar_peliculas(Criterios,Edad,Resultados) :-                                % R25
    is_list(Criterios),integer(Edad),Edad>= -1,
    findall(P,(member(C,Criterios),coincidencia(P,C,_,_),
                criterio_admisible(P,C),edad_habilitada(P,Edad)),Duplicados),
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
    split_string(Minusculas," \t\n\r,.;:!?¿¡"," \t\n\r",Palabras),
    maplist(atom_string,Atoms,Palabras),
    findall(C,(member(Atom,Atoms),sinonimo(Atom,C)),CriteriosTematicos),
    findall(CT,(titulo_consulta(CT,_,Secuencia),
                contiene_secuencia(Secuencia,Atoms)),CriteriosTitulo),
    append(CriteriosTematicos,CriteriosTitulo,Todos),
    sort(Todos,Criterios).
estado_consulta(Consulta,_,_,consulta_vacia) :-                               % R27
    (Consulta=="";Consulta==''),!.
estado_consulta(_,[],_,criterio_no_reconocido) :- !.
estado_consulta(_,_,[],sin_resultados) :- !.
estado_consulta(_,_,_,ok).
criterio_admisible(P,C) :- titulo_consulta(C,P,_),!.                          % R29
criterio_admisible(P,infantil) :- !,apta_para_ninos(P).
criterio_admisible(P,terror) :- !,genero_validado(P,terror).
criterio_admisible(_,_).

% ENTREGABLE 2: EXPLICABILIDAD Y RECOMENDACIÓN (R30-R45)
regla_catalogo(r01,'Validación de película','Se comprobó que la película existe en el catálogo.').
regla_catalogo(r02,'Validación de género','El género consultado está registrado para la película.').
regla_catalogo(r03,'Validación de etiqueta','La etiqueta consultada está registrada para la película.').
regla_catalogo(r04,'Validación temática','La sinopsis posee el tema indexado consultado.').
regla_catalogo(r05,'Validación etaria','La edad mínima es un entero válido y no negativo.').
regla_catalogo(r11,'Percepción recurrente','Dos o más autores independientes comparten la percepción.').
regla_catalogo(r12,'Aptitud infantil','Combina edad, orientación familiar y ausencia de terror.').
regla_catalogo(r13,'Coincidencia por género','Activa evidencia editorial de género.').
regla_catalogo(r14,'Coincidencia por etiqueta','Activa evidencia editorial de etiqueta.').
regla_catalogo(r15,'Coincidencia por sinopsis','Activa evidencia temática de sinopsis.').
regla_catalogo(r16,'Coincidencia por opiniones','Activa evidencia cuando la percepción es recurrente.').
regla_catalogo(r17,'Coincidencia infantil','Activa la conclusión de aptitud infantil.').
regla_catalogo(r18,'Coincidencia por título','El texto ingresado coincide con un título indexado del catálogo.').
regla_catalogo(r19,'Peso de la fuente','Asigna prioridad según la confiabilidad de la fuente.').
regla_catalogo(r24,'Construcción de hipótesis','Integra hechos, evidencias, cobertura y nivel.').
regla_catalogo(r25,'Selección y ranking','Deduplica y ordena hipótesis por puntaje simbólico.').
regla_fuente(genero,r02). regla_fuente(genero,r13).
regla_fuente(etiqueta,r03). regla_fuente(etiqueta,r14).
regla_fuente(sinopsis,r04). regla_fuente(sinopsis,r15).
regla_fuente(opiniones,r11). regla_fuente(opiniones,r16).
regla_fuente(clasificacion_infantil,r05).
regla_fuente(clasificacion_infantil,r12).
regla_fuente(clasificacion_infantil,r17).
regla_fuente(titulo,r18).
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
    format(atom(Texto),'opiniones_recurrentes(~w, ~w, ~w)',[P,C,Autores]).
hecho_evidencia(P,infantil,clasificacion_infantil,Texto) :-
    edad_minima(P,Min),format(atom(Texto),
    'edad_minima(~w, ~d) y orientación infantil sin terror',[P,Min]).
hecho_evidencia(P,C,titulo,Texto) :-
    titulo_consulta(C,P,_),pelicula(P,Titulo,_),
    format(atom(Texto),'titulo_coincidente(~w, "~w")',[P,Titulo]).
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
    assert_resena_usuario(P,Autor,Texto,Percepcion,Calificacion,Fecha),
    autores_percepcion(P,Percepcion,AutoresPercepcion),
    ( AutoresPercepcion>=2 -> Activa=true,
      Mensaje='La percepción ya participa en la inferencia por recurrencia.'
    ; Activa=false,
      Mensaje='La reseña fue guardada; se requieren dos autores para activar esta percepción.' ),
    listar_resenas(P,Resenas),length(Resenas,Total),
    calificacion_promedio(P,Promedio),
    atom_json_dict(Json,_{ok:true,pelicula:P,total_resenas:Total,
        calificacion_promedio:Promedio,percepcion:Percepcion,
        autores_percepcion:AutoresPercepcion,activa_inferencia:Activa,
        mensaje:Mensaje},[]).

% R44: punto de entrada auditable. El JSON es el único contrato con Python.
buscar_json(Consulta,Edad,Json) :-
    ground(Consulta),integer(Edad),Edad>= -1,
    consulta_a_criterios(Consulta,Criterios),buscar_peliculas(Criterios,Edad,Resultados),
    estado_consulta(Consulta,Criterios,Resultados,Estado),length(Resultados,Total),
    hipotesis_competencia(Resultados,Competidores),
    decision_motor(Criterios,Resultados,Competidores,Decision),
    auditoria_motor(Criterios,Edad,Resultados,Competidores,Auditoria),
    atom_json_dict(Json,_{consulta:Consulta,criterios:Criterios,
      edad_consultada:Edad,estado:Estado,total:Total,resultados:Resultados,
      decision:Decision,auditoria:Auditoria},[]).
buscar_json(Consulta,Json) :- buscar_json(Consulta,-1,Json).                   % R45
