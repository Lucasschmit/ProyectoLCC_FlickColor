:- module(proylcc, 
	[  
		flick/6
	]).


:- dynamic visitado/1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Recibe una lista de listas, y retorna una lista identica a la recibida, solo que si alguna lista estaba vacia, no sera incluida

eliminar_listas_vacias([[]|Cola], Cola).
eliminar_listas_vacias([Elem], [Elem]).
eliminar_listas_vacias([X|Cola], Lres) :-
    eliminar_listas_vacias(Cola, Laux),
    Lres = [X|Laux].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

adyacente_superior(_Grilla, [_Xpos, 0], []).
adyacente_superior(_Grilla, [Xpos, Ypos], [Xpos, Ysup]) :- Ysup is -(Ypos, 1).

adyacente_izquierda(_Grilla, [0, _Ypos], []).
adyacente_izquierda(_Grilla, [Xpos, Ypos], [Xizq, Ypos]) :- Xizq is -(Xpos, 1).

adyacente_inferior(Grilla, [_Xpos, AltoGrilla], []) :-
    length(Grilla, FilasGrilla),
    AltoGrilla is -(FilasGrilla, 1).
adyacente_inferior(_Grilla, [Xpos, Ypos], [Xpos, Yinf]) :- Yinf is +(Ypos, 1).

adyacente_derecha(Grilla, [AnchoGrilla, _Ypos], []) :-
    Grilla = [Fila|_],
    length(Fila, ColumnasGrilla),
    AnchoGrilla is -(ColumnasGrilla, 1).
adyacente_derecha(_Grilla, [Xpos, Ypos], [Xder, Ypos]) :- Xder is +(Xpos, 1).

adyacentes_verticales(Grilla, [Xpos, Ypos], ListaResultado) :-
    adyacente_superior(Grilla, [Xpos, Ypos], AdyacenteSuperior),
    adyacente_inferior(Grilla, [Xpos, Ypos], AdyacenteInferior),
    eliminar_listas_vacias([AdyacenteSuperior, AdyacenteInferior], ListaResultado).

adyacentes_horizontales(Grilla, [Xpos, Ypos], ListaResultado) :-
    adyacente_derecha(Grilla, [Xpos, Ypos], AdyacenteDerecha),
    adyacente_izquierda(Grilla, [Xpos, Ypos], AdyacenteIzquierda),
    eliminar_listas_vacias([AdyacenteDerecha, [Xpos, Ypos], AdyacenteIzquierda], ListaResultado).

%Calcula las celdas adyacentes a [Xpos, Ypos] y las retorna en una lista. Ademas, incluye a [Xpos, Ypos] en esa lista
adyacentes_de_celda(Grilla, [Xpos, Ypos], ListaResultado) :-
    adyacentes_horizontales(Grilla, [Xpos, Ypos], AdyacentesHorizontales),
    adyacentes_verticales(Grilla, [Xpos, Ypos], AdyacentesVerticales),
    append(AdyacentesHorizontales, AdyacentesVerticales, Adyacentes),
    eliminar_listas_vacias(Adyacentes, ListaResultado).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Calcula el Color de la posicion [X, Y] en la Grilla
color_en_pos(Grilla, [X, Y], Color) :-
    nth0(Y, Grilla, Fila),
    nth0(X, Fila, Color).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Calcula las posiciones adyacentes a [X,Y] que sean del mismo color
adyacentes_del_mismo_color(Grilla, [X, Y], AdyacentesDelMismoColor) :-
    adyacentes_de_celda(Grilla, [X,Y], Adyacentes),
    color_en_pos(Grilla, [X, Y], Color),
    findall([X1, Y1], (member([X1, Y1], Adyacentes), color_en_pos(Grilla, [X1, Y1], Color)), AdyacentesDelMismoColor).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

posiciones_fila(0, Y, Posiciones) :-
    Posiciones = [[0, Y]].
    
posiciones_fila(X, Y, Posiciones) :-
    >(X, 0),
    Posiciones = [[X, Y]|PosicionesCola],
    Xnew is -(X, 1),
    posiciones_fila(Xnew, Y, PosicionesCola).

posiciones_en_grilla(Ancho, 0, Posiciones) :-
    posiciones_fila(Ancho, 0, Posiciones).

posiciones_en_grilla(Ancho, Alto, Posiciones) :-
    AltoNew is -(Alto, 1),
    posiciones_en_grilla(Ancho, AltoNew, PosicionesCola1),
    posiciones_fila(Ancho, Alto, PosicionesCola2),
    append(PosicionesCola2, PosicionesCola1, Posiciones).

%Devuelve una lista con todas las posiciones de la grilla.
%Es decir, todos los pares [X,Y] tal que la grilla tiene un valor de color en la fila Y, Columna X.

%Se utiliza una tecnica similar a la utilizada para actualizar los colores
posiciones(Grilla, Posiciones) :-
    Grilla = [Fila|_],
	length(Grilla, AltoAux),
    length(Fila, AnchoAux),
    Alto is -(AltoAux, 1),
    Ancho is -(AnchoAux, 1),
	posiciones_en_grilla(Ancho, Alto, Posiciones).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


visitar(A) :- assert(visitado(A)).

%Estamos visitando la celda de origen. Es donde deberia entrar la primera vez que invocamos el predicado
encontrar_adyacentes_C_optimizado(Grilla, PosOrigen, PosOrigen, ListaAdyacentesC) :-
    not(visitado(PosOrigen)),
    visitar(PosOrigen),
    adyacentes_del_mismo_color(Grilla, PosOrigen, AdyacentesDelMismoColor),
	findall(A, (member(A, AdyacentesDelMismoColor), encontrar_adyacentes_C_optimizado(Grilla, PosOrigen, A, _L1)), _L2),	%Llamado recursivo
    findall(B, visitado(B), ListaAdyacentesC),
    retractall(visitado(A)).

%Estamos vistando alguna celda AdyacenteC* a la de origen, pero no la de origen.
encontrar_adyacentes_C_optimizado(Grilla, PosOrigen, Pos, _ListaAdyacentesC) :-
    not(visitado(Pos)),
    visitar(Pos),
    adyacentes_del_mismo_color(Grilla, Pos, AdyacentesDelMismoColor),
    findall(A, (member(A, AdyacentesDelMismoColor), encontrar_adyacentes_C_optimizado(Grilla, PosOrigen, A, _L1)), _L2).	%Llamado recursivo
  

%Recibe una lista de posiciones ordenada y completa, y una lista de posiciones desordenadas, no necesariamente completa.
%Computa una lista que contiene a todas las posiciones de la lista desordenada, pero esta vez ordenadas
ordenar_posiciones(Posiciones, PosicionesDesordenadas, PosicionesOrdenadas) :-
    findall(Pos, (member(Pos, Posiciones), member(Pos, PosicionesDesordenadas)), PosicionesOrdenadas).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%caso: Estoy en la posicion que tengo que cambiar
cambiar_colores_fila(FilaOriginal, NroFila, [[X, NroFila]|RestoPosiciones], ColorNuevo, X, FilaDestino, PosicionesRestantes) :-
    Xnext is -(X, 1),
    cambiar_colores_fila(FilaOriginal, NroFila, RestoPosiciones, ColorNuevo, Xnext, RestoFilaDestino, PosicionesRestantes),
    append(RestoFilaDestino, [ColorNuevo], FilaDestino).

%caso: No estoy en la posicion que tengo que cambiar, pero si en la fila, me quedan posiciones
cambiar_colores_fila(FilaOriginal, NroFila, [[A, NroFila]|RestoPosiciones], ColorNuevo, X, FilaDestino, PosicionesRestantes) :-
    >=(X, 0),
    nth0(X, FilaOriginal, ColorViejo),
    Xnext is -(X, 1),
    cambiar_colores_fila(FilaOriginal, NroFila, [[A, NroFila]|RestoPosiciones], ColorNuevo, Xnext, RestoFilaDestino, PosicionesRestantes),
    append(RestoFilaDestino, [ColorViejo], FilaDestino).

%caso: Las posiciones que quedan son de otra fila
cambiar_colores_fila(FilaOriginal, NroFila, [[A, B]|RestoPosiciones], ColorNuevo, X, FilaDestino, [[A, B]|RestoPosiciones]) :-
    \=(NroFila, B),
    >=(X, 0),
    nth0(X, FilaOriginal, ColorViejo),
    Xnext is -(X, 1),
    cambiar_colores_fila(FilaOriginal, NroFila, [[A, B]|RestoPosiciones], ColorNuevo, Xnext, RestoFilaDestino, [[A, B]|RestoPosiciones]),
    append(RestoFilaDestino, [ColorViejo], FilaDestino).

%caso: no me quedan posiciones, pero tengo que completar la fila
cambiar_colores_fila(FilaOriginal, NroFila, [], ColorNuevo, X, FilaDestino, []) :-
    >=(X, 0),
    nth0(X, FilaOriginal, ColorViejo),
    Xnext is -(X, 1),
    cambiar_colores_fila(FilaOriginal, NroFila, [], ColorNuevo, Xnext, RestoFilaDestino, []),
    append(RestoFilaDestino, [ColorViejo], FilaDestino).

%caso: Ya completamos toda la fila
cambiar_colores_fila(_FilaOriginal, NroFila, [[A, B]|RestoPosiciones], _ColorNuevo, X, [], [[A, B]|RestoPosiciones]) :-
    \=(NroFila, B),
    <(X, 0).

%caso: No quedan posiciones por reemplazar
cambiar_colores_fila(_FilaOriginal, _NroFila, [], _ColorNuevo, X, [], []) :-
    <(X, 0).



%Asume que las posiciones estan ordenadas por fila. Es decir, todas las celdas estan agrupadas por la fila a la que pertenecen.
%Ademas, Las filas inferiores van antes que las superiores
%Ademas, aparecen de derecha a izquierda.
/*
Ejemplo: [[12, 3], [10, 3], [5, 2], [5, 1], [5, 0]]
*/

%caso: no hay mas filas, ni posiciones
cambiar_color(_GrillaOriginal, NroFila, [], _ColorNuevo, []) :-
    <(NroFila, 0).

%caso: La primer posicion a cambiar corresponde a la fila que estamos revisando
cambiar_color(GrillaOriginal, NroFila, PosicionesACambiar, ColorNuevo, GrillaResultado) :-
    PosicionesACambiar = [[_, NroFila]|_],
    nth0(NroFila, GrillaOriginal, Fila),
    length(Fila, AnchoAux),
    Ancho is -(AnchoAux, 1),
    cambiar_colores_fila(Fila, NroFila, PosicionesACambiar, ColorNuevo, Ancho, FilaNueva, PosicionesRestantes),
    NroFilaNext is -(NroFila, 1),
    cambiar_color(GrillaOriginal, NroFilaNext, PosicionesRestantes, ColorNuevo, GrillaResultadoAuxiliar),
    append(GrillaResultadoAuxiliar, [FilaNueva], GrillaResultado).

%caso: Pueden haber posiciones por revisar. Quedan filas por copiar
cambiar_color(GrillaOriginal, NroFila, PosicionesPorRevisar, ColorNuevo, GrillaResultado) :-
	nth0(NroFila, GrillaOriginal, Fila),
    NroFilaNext is -(NroFila, 1),
    cambiar_color(GrillaOriginal, NroFilaNext, PosicionesPorRevisar, ColorNuevo, GrillaResultadoAuxiliar),
    append(GrillaResultadoAuxiliar, [Fila], GrillaResultado).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

estado_juego_optimizado(Grilla, CantidadCapturadas, 1) :-
    length(Grilla, Alto),
    nth0(0, Grilla, Fila),
    length(Fila, Ancho),
    CantTotalCeldas is *(Ancho, Alto),
    CantidadCapturadas = CantTotalCeldas.

estado_juego_optimizado(_Grilla, _Capturadas, 0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

flick(Grilla, [X, Y], Color, GrillaResultado, CantidadCeldasCapturadas, EstadoJuego) :-
    color_en_pos(Grilla, [X, Y], ColorEnPos),
    \=(Color, ColorEnPos),
    
	posiciones(Grilla, Posiciones),
    
	encontrar_adyacentes_C_optimizado(Grilla, [X, Y], [X, Y], AdyacentesCDesordenadas),
    ordenar_posiciones(Posiciones, AdyacentesCDesordenadas, AdyacentesC),
    
	length(Grilla, AltoTotal),
    AltoUtil is -(AltoTotal, 1),
    cambiar_color(Grilla, AltoUtil, AdyacentesC, Color, GrillaResultado),
    
    encontrar_adyacentes_C_optimizado(GrillaResultado, [X, Y], [X, Y], CeldasCapturadas),
    length(CeldasCapturadas, CantidadCeldasCapturadas),
    
    estado_juego_optimizado(Grilla, CantidadCeldasCapturadas, EstadoJuego).