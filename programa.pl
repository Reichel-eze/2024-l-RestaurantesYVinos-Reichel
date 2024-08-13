% Parcial Restaurantes y Vinos 

%restaurante(Nombre, CantidadEstrellas, BarrioUbicacion)
restaurante(panchoMayo, 2, barracas).
restaurante(finoli, 3, villaCrespo).
restaurante(superFinoli, 5, villaCrespo).

%menu(Restaurante, Menu)
menu(panchoMayo, carta(1000, pancho)).
menu(panchoMayo, carta(200, hamburguesa)).
menu(finoli, carta(2000, hamburguesa)).
menu(finoli, pasos(15, 15000, [chateauMessi, francescoliSangiovese, susanaBalboaMalbec], 6)).
menu(noTanFinoli, pasos(2, 3000, [guinoPin, juanaDama],3)).

% PARA EL PUNTO 6)
%menu(Restaurante, experiencia(cantPlatos, cantDias, precioPorDia, vinos, comensales)). 
menu(ezequielini, experiencia(10, 3, 20000, [chateauMessi, francescoliSangiovese, juanaDama], 5)).

% carta(Precio, Plato)
% pasos(N°De Pasos, Precio, ListaDeVinos, Cantidad Comensales)

%vino(Nombre, PaisOrigen, Precio)
vino(chateauMessi, francia, 5000).
vino(francescoliSangiovese, italia, 1000).
vino(susanaBalboaMalbec, argentina, 1200).
vino(christineLagardeCabernet, argentina, 5200).
vino(guinoPin, argentina, 500).
vino(juanaDama, argentina, 1000).

% 1) Cuáles son los restaurantes de más de N estrellas por barrio.
% Por ejemplo: ¿Cuáles son los restaurantes de mas de 2 estrellas
% en villa crespo? finoli y superFinoli

restauranteDeMasEstrellasDelBarrio(Restaurante, N, Barrio) :-
    restaurante(Restaurante, Cantidad, Barrio),
    Cantidad > N.

% 2) Cuáles son los restaurantes sin estrellas.
% Por ejemplo: ¿Cuáles son los restaurantes sin estrellas? noTanFinoli

restauranteSinEstrellas(Restaurante) :-
    menu(Restaurante, _),
    not(restaurante(Restaurante, _, _)).

% 3) Si un restaurante está mal organizado, que es cuando tiene
% algún menú que tiene más pasos que la cantidad de vinos disponibles 
% o cuando tiene en su menú a la carta dos veces una misma comida 
% con diferente precio.
% Por ejemplo:
% - ¿Está mal organizado finoli? Si
% - ¿Está mal organizado panchoMayo? No

malOrganizado(Restaurante) :-
    menu(Restaurante, pasos(CantidadPasos, _, ListaDeVinos, _)),
    length(ListaDeVinos, CantidadVinos),
    CantidadPasos > CantidadVinos.

malOrganizado(Restaurante) :-
    menu(Restaurante, carta(Precio1, Comida)),
    menu(Restaurante, carta(Precio2, Comida)),
    Precio1 \= Precio2.

% --- VERSIONES CON FUNCIONES AUXILIARES ---

estaMalOrganizadoV2(Restaurante) :-
    menu(Restaurante, Menu),
    malMenu(Menu).

estaMalOrganizadoV2(Restaurante) :-
    mismaComida(Restaurante).

malMenu(pasos(CantidadPasos, _, ListaDeVinos, _)) :-
    length(ListaDeVinos, CantidadVinos),
    CantidadPasos > CantidadVinos. 

mismaComida(Restaurante) :-
    menu(Restaurante, carta(Precio, Comida)),
    menu(Restaurante, carta(OtroPrecio, Comida)),
    Precio \= OtroPrecio.

% 4) Qué restaurante es copia barata de qué otro restaurante, 
% lo que sucede cuando el primero tiene todos los platos a la carta
% que ofrece el otro restaurante, pero a un precio menor. 
% Además, no puede tener más estrellas que el otro. 

% ¿Existe algún restaurante que sea copia barata de otro? Si, panchoMayo de finoli
% ¿Existe algún restaurante que sea copia barata de panchoMayo? No

copiaBarata(RestauranteCopia, RestauranteCopiado) :-
    menu(RestauranteCopia, _),
    menu(RestauranteCopiado, _),
    RestauranteCopia \= RestauranteCopiado,
    forall(menu(RestauranteCopiado, carta(PrecioCopiado, Comida)), (menu(RestauranteCopia, carta(PrecioCopia, Comida)), PrecioCopia < PrecioCopiado)),
    % para todos los platos que ofrece el restaurante copiado, los tiene el restaurante copia pero con menor precio
    %not(tieneMasEstrellas(RestauranteCopia, RestauranteCopiado)).
    tieneMenosEstrellas(RestauranteCopia, RestauranteCopiado).

platosALaCarta(Restaurante, Platos) :-
    findall(carta(Dinero, Plato), menu(Restaurante, carta(Dinero, Plato)), Platos).
    
tieneMasEstrellas(R1, R2) :-
    restaurante(R1, Estrellas1, _),
    restaurante(R2, Estrellas2, _),
    Estrellas1 > Estrellas2. 

tieneMenosEstrellas(R1, R2) :-
    restaurante(R1, Estrellas1, _),
    restaurante(R2, Estrellas2, _),
    Estrellas1 < Estrellas2.

% 5) Cuál es el precio promedio de los menúes de cada restaurante, por persona. 
% - En los platos, se considera el precio indicado ya que se asume que es para una persona.
% - En los menú por pasos, el precio es el indicado más la suma de los precios de todos los vinos incluidos, 
% - pero dividido en la cantidad de comensales. Los vinos importados pagan una tasa aduanera del 35% por sobre su precio publicado.

% ¿Cuáles son los precios promedio de los restaurantes?
% - De panchoMayo, 600$ -> (1000 + 200) / 2
% - De finoli, 3025$            -> (2000 + (15000 + (5000 * 1.35 + 1000 * 1.35  + 1200))/6) / 2
% . De noTanFinoli, 1500$ -> (3000 + (500 + 1000)) / 3 

precioPromedioPorPersona(Restaurante, PrecioPromedio) :-
    menu(Restaurante, _),
    findall(PrecioMenu, (menu(Restaurante, Menu), precioMenu(Menu, PrecioMenu)), Precios),
    sum_list(Precios, SumatoriaPrecios),
    cantidadPersonas(Restaurante, Cantidad),
    PrecioPromedio is SumatoriaPrecios / Cantidad.

precioMenu(carta(Precio, _), Precio).                                           % el precio del menu cuando es una carta

precioMenu(pasos(_, PrecioBase, ListaDeVinos, CantidadComensales), Precio) :-   % el precio del menu cuando es por pasos
    precioListaDeVinos(ListaDeVinos, TotalPreciosVinos),
    %PrecioConVinos is PrecioBase + TotalPreciosVinos,
    %Precio is PrecioConVinos / CantidadComensales.
    Precio is (PrecioBase + TotalPreciosVinos) / CantidadComensales.            % el menu por pasos lo divide segun la cantidad de comensales
      
% AGREGO PARA EL PUNTO 6) EL COMO CALCULAR EL PRECIO
precioMenu(experiencia(_, _, PrecioPorDia, ListaDeVinos, CantidadComensales), Precio) :-
    precioListaDeVinos(ListaDeVinos, TotalPreciosVinos), 
    Precio is (PrecioPorDia * TotalPreciosVinos) / CantidadComensales.

% -----------------------------------------------------

precioListaDeVinos(ListaDeVinos, TotalPreciosVinos) :-
    findall(Precio, (member(Vino, ListaDeVinos), precioVino(Vino, Precio)), PreciosVinos),
    sum_list(PreciosVinos, TotalPreciosVinos).

%precioVino(vino(_, argentina, Precio), Precio).
%precioVino(vino(_, Pais, PrecioBase), Precio) :-
%    Pais \= argentina, 
%    Precio is PrecioBase * (1 + 0.35).

%vinoImportado :- vino(_, Pais, _), Pais \= argentina.    

precioVino(Vino, Precio) :-
    vino(Vino, argentina, Precio).

precioVino(Vino, Precio) :-
    vino(Vino, Pais, PrecioBase),
    Pais \= argentina,
    Precio is PrecioBase * 1.35.

cantidadPersonas(Restaurante, Cantidad) :-              % cantidad de Menus que tiene el restaurante
    findall(Menu, menu(Restaurante, Menu), Menus),
    length(Menus, Cantidad).

% 6) Inventar un nuevo tipo de menú diferente a los anteriores, con su correspondiente forma de calcular el precio. 
% ¿Qué podría hacerse en relación a los restaurantes mal organizados o copias baratas? Justificar.