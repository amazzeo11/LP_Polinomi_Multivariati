%%%Mazzeo Alessia 899612



%%% is_monomial/1:
%%% monomi in forma: m(Coefficient, TotalDegree, VarsPowers)

is_monomial(m(_C, TD, VPs)) :-
    integer(TD),
    TD >= 0,
    is_list(VPs).



%%% is_varpower/1:
%%% potenze in forma: v(Power, VarSymbol)

is_varpower(v(Power, VarSymbol)) :-
    integer(Power),
    Power >=0,
    atom(VarSymbol).


%%% is_polynomial/1:
%%% polinomi nella forma: poly(monomials)

is_polynomial(poly(Monomials)) :-
    is_list(Monomials),
    foreach(member(M, Monomials), is_monomial(M)).



%%%is_zero/1:
%is_zero([]):- !.
%
is_zero(X) :-
    is_monomial(X),
    X = m(0, 0, []),
    !.

%is_zero(m(C, _, _)) :-
 %   C =:= 0.

is_zero(poly([])):- !.

is_zero(X) :-
    is_polynomial(X),
    X = poly(M),
    foreach(member(Y, M), is_zero(Y)).



%%% as_monomial/2:
%%% ordinamento in modo crescente per grado
%%% con spareggio rispetto alle variabili
as_monomial(E, m(C, T, V)) :-
    first_symbol(E, S),
    integer(S),
    C is S,
    total_degree(E, TotalDegree),
    !,
    T is TotalDegree,
    var_powers(E, Varpws),
    sort(1,@>=,Varpws,Vs),
    sort(2,@=<,Vs,Vps),
    V = Vps.

%%%caso in cui il coefficiente del monomio non � esplicito
as_monomial(E, m(C, T, V)) :-
    first_symbol(E, S),
    \+integer(S),
    C is 1,
    total_degree(E, TotalDegree),
    !,
    T is TotalDegree,
    var_powers(E, Varpws),
    sort(1,@>=,Varpws,Vs),
    sort(2,@=<,Vs,Vps),
    V = Vps.

as_monomial(E, m(C, T, V)) :-
    first_symbol(E, S),
    S = -,
    C is -1,
    total_degree(E, TotalDegree),
    !,
    T is TotalDegree,
    var_powers(E, Varpws),
    sort(1,@>=,Varpws,Vs),
    sort(2,@=<,Vs,Vps),
    V = Vps.

%%% first_symbol/2:
%%% estrae il primo simbolo dall'espressione E

first_symbol(E, E) :-
    (number(E); atom(E)), !.

first_symbol(E, Symbol) :-
    E =.. [_ | Args],  % Decompose the term into functor and arguments
    Args = [First | _],  % Get the first argument,
    first_symbol(First, Symbol).  % Recursively find the first symbol


%%% grado totale/2:
%%% calcola il grado complessivo del monomio

total_degree(E, TotalDegree) :-
    decompose_m(E, Terms),
    extract_exp(Terms, Exp),
    ssum_list(Exp, TotalDegree).


%%% scomponi/2:
%%% Scompone il monomio in termini singoli

decompose_m(E, [E]) :-
    atomic(E),
    !.

decompose_m(E, Terms) :-
    E =.. [*, T1, T2],
    decompose_m(T1, Term1),
    decompose_m(T2, Term2),
    !,
    append(Term1, Term2, Terms).

decompose_m(E, [E]) :-
    E =.. [_ | _].


%%% estrai_esponenti/2:
%%% Estrae gli esponenti delle variabili dai singoli termini

extract_exp([], []).
extract_exp([E | Rest], [1 | Exp]) :-
    atomic(E),
    \+ integer(E),
    !,
    extract_exp(Rest, Exp).

extract_exp([_^Exp | Rest], [Exp | Exps]) :-
    !,
    extract_exp(Rest, Exps).

extract_exp([_ | Rest], Exps) :-
    extract_exp(Rest, Exps).

%%% somma_lista/2:
%%% Calcola la somma degli elementi della lista

ssum_list([], 0).
ssum_list([H | T], Sum) :-
    ssum_list(T, Rest),
    Sum is H + Rest.


var_powers(E, V) :-
    decompose_m(E, E1),
    maplist(convert_vp, E1, V1),
    !,
    exclude(==(null), V1, V).


convert_vp(T, v(Exp, S)) :-
    T =.. [^, S, Exp].

convert_vp(T, v(1, T)) :-
    atomic(T),
   \+integer(T).

convert_vp(T, null) :-
    T =.. [_|_].


as_polynomial(E, poly(P)) :-
    decompose_p(E,M),
    sort(1,@=<,M,Ms),
    maplist(as_monomial, Ms, Ps),
    sort(2,@=<,Ps,P).



% Regola per l'addizione
decompose_p(E, Terms) :-
    E =.. [+, T1, T2],
    decompose_p(T1, Term1),
    decompose_p(T2, Term2),
    !,
    append(Term1, Term2, Terms).

% Regola per la sottrazione
decompose_p(E, Terms) :-
    E =.. [-, T1, T2],
    decompose_p(T1, T1s),
    decompose_negative(T2, T2Neg),
    !,
    append(T1s, T2Neg, Terms).

% Regola per il caso base: il termine � un monomio
decompose_p(E, [E]) :-
    E =.. [_ | _],
    !.

% Regola per il caso base: il termine � una costante
decompose_p(E, [E]) :-
    atomic(E),
    !.

% Funzione di supporto per negare i termini
decompose_negative(E, NegTerms) :-
    E =.. [+, T1, T2],
    decompose_negative(T1, T1Neg),
    decompose_negative(T2, T2Neg),
    !,
    append(T1Neg, T2Neg, NegTerms).

decompose_negative(E, NegTerms) :-
    E =.. [-, T1, T2],
    decompose_negative(T1, T1Neg),
    decompose_p(T2, T2s),
    !,
    append(T1Neg, T2s, NegTerms).

decompose_negative(E, [ENeg]) :-
    E =.. [Op, C, Var],
    (Op = * -> CNeg is -C, ENeg =.. [*, CNeg, Var]
    ; Op = ^ -> CNeg is -1, ENeg =.. [*, CNeg, E]
    ; atomic(E) -> ENeg is -E
    ; ENeg =.. [(-), E]
    ),
    !.

decompose_negative(E, [ENeg]) :-
    atomic(E),
    ENeg is -E,
    !.

% Definizione del predicato principale per la stampa del polinomio
pprint_polynomial(poly(M)) :-
    maplist(m_to_string, M, Terms),
    atomic_list_concat(Terms, '', P),
    writeln(P).

% Conversione di un monomio in una stringa
m_to_string(m(C, _D, V), Term) :-
    c_to_string(C, Cs),
    C>=0,!,
    v_to_string(V, Vs),
    format(atom(Term), '+~w~w', [Cs, Vs]).

m_to_string(m(C, _, V), Term) :-
    c_to_string(C, Cs),
    C<0,!,
    v_to_string(V, Vs),
    format(atom(Term), '~w~w', [Cs, Vs]).


% Conversione del coefficiente in stringa
c_to_string(C, '') :- C =:= 1, !.
c_to_string(C, Cs) :-
    number_string(C, Cs).

% Conversione delle variabili in stringa
v_to_string([], '').
v_to_string([v(Exp, N) | Vars], Vs) :-
    ( Exp =:= 1 ->
        format(atom(V), '~w', [N])
    ;
        format(atom(V), '~w^~w', [N, Exp])
    ),
    v_to_string(Vars, RestVs),
    atom_concat(V, RestVs, Vs).



%%%coefficients/2:
coefficients(poly(P), C) :-
    maplist(extract_coeff, P, C).

extract_coeff(m(C,_,_), Cs) :-
    append([],C,Cs).


%monomials/2:

monomials(poly(P), P).


%min_degree/2:
%
min_degree(poly([m(_,D,_)|_]), D).

%max_degree/2:

max_degree(poly(P), D):- sort(2,@>=,P,Ps), Ps = [m(_,D,_)|_].


%da poly in tradizionale restituisce monomi in tradizionale
monomials_t(P,M):-
    decompose_p(P,Ms),
    sort(1,@<,Ms,M).

%da poly parser a lista var senza duplicati
variables(poly(P),V) :-
    maplist(extract_v, P, Ps),
    flatten(Ps,V).

extract_v(m(_,_,V), Vs) :-
    append([],V,Vs).

%restituisce solo i simboli di variabili
only_variables(poly(P),V) :-
    variables(poly(P),Vs),
    maplist(arg(2), Vs, D),
    list_to_set(D,V).

% Predicato principale
mvp_plus(poly(M1), poly(M2), poly(Result)) :-
    append(M1, M2, Ms),
    sum_ms(Ms, Mc),!,
    remove_zeros(Mc, Result).

% Somma monomi con lo stesso TotalDegree e VarPowers
sum_ms([], []).
sum_ms([m(C, TD, VP) | T], [m(CS, TD, VP) | R]) :-
    sum_m(m(C, TD, VP), T, CS, T1),
    sum_ms(T1, R).

% Somma un singolo monomio con quelli uguali nella lista
sum_m(m(C, _, _), [], C, []).
sum_m(m(C, TD, VP), [m(C1, TD, VP) | T], CS, R) :-
    CS1 is C + C1,
    sum_m(m(CS1, TD, VP), T, CS, R).
sum_m(M, [H | T], CS, [H | R]) :-
    sum_m(M, T, CS, R).

% Rimuovi monomi con coefficiente zero
remove_zeros([], []).
remove_zeros([m(0, _, _) | T], R) :-
    remove_zeros(T, R).
remove_zeros([H | T], [H | R]) :-
    remove_zeros(T, R).


% Predicato principale per la sottrazione
mvp_minus(poly(M1), poly(M2), poly(Result)) :-
    reverse_s(M2, M2Neg),
    append(M1, M2Neg, MT),
    sum_ms(MT, MC),!,
    remove_zeros(MC, Result),!.

% Inverti i segni dei coefficienti dei monomi
reverse_s([], []).
reverse_s([m(C, TD, VP) | T], [m(CNeg, TD, VP) | T1]) :-
    CNeg is -C,
    reverse_s(T, T1).




% Predicato principale per la moltiplicazione di un polinomio con un monomio

% Moltiplica ciascun monomio del polinomio con il monomio dato
mvp_times_m(poly(Monomi), Monomio, poly(Result)) :-
    moltiplica_monomi(Monomi, Monomio, Result).

moltiplica_monomi([], _, []).
moltiplica_monomi([m(Coeff1, TD1, VP1) | T], m(Coeff2, TD2, VP2), [m(Coeff, TD, VP) | R]) :-
    Coeff is Coeff1 * Coeff2,
    TD is TD1 + TD2,
    append(VP1, VP2, VPList),
    combina_var_powers(VPList, VP),
    moltiplica_monomi(T, m(Coeff2, TD2, VP2), R).

% Combina i var powers di due monomi (somma le potenze delle variabili uguali)
combina_var_powers(VPList, Result) :-
    combina_var_powers(VPList, [], Result).

combina_var_powers([], Acc, Acc).
combina_var_powers([v(D1, X) | T], Acc, Result) :-
    ( select(v(D2, X), Acc, Rest) ->
        D is D1 + D2,
        combina_var_powers(T, [v(D, X) | Rest], Result)
    ; combina_var_powers(T, [v(D1, X) | Acc], Result)
    ).




% Moltiplica due polinomi
mvp_times(poly(Monomi1), poly(Monomi2), poly(Result)) :-
    findall(m(Coeff, TD, VP),
            (member(M1, Monomi1), member(M2, Monomi2),
             mvp_times(M1, M2, m(Coeff, TD, VP))),
            MonomiProdotti),
    somma_monomi_simili(MonomiProdotti, MonomiSommati),
    % Rimuove i monomi con coefficiente 0
    exclude(zero_coeff, MonomiSommati, Result).




% Moltiplica due monomi
mvp_times(m(Coeff1, TD1, VP1), m(Coeff2, TD2, VP2), m(Coeff, TD, VP)) :-
    Coeff is Coeff1 * Coeff2,
    TD is TD1 + TD2,
    append(VP1, VP2, VPList),
    combina_var_powers(VPList, VP).

% Verifica se un monomio ha coefficiente zero
zero_coeff(m(Coeff, _, _)) :- Coeff =:= 0.


% Ordina le variabili in ogni monomio per facilitare il confronto
ordina_monomi([], []).
ordina_monomi([m(Coeff, TD, VP) | T], [m(Coeff, TD, SortedVP) | SortedT]) :-
    sort(2, @=<, VP, SortedVP),
    ordina_monomi(T, SortedT).

% Somma monomi simili (con la stessa combinazione di variabili e potenze)
somma_monomi_simili(Monomi, Result) :-
    ordina_monomi(Monomi, MonomiOrdinati),
    somma_monomi_simili(MonomiOrdinati, [], Result).

somma_monomi_simili([], Acc, Acc).
somma_monomi_simili([m(Coeff1, TD, VP) | T], Acc, Result) :-
    ( select(m(Coeff2, TD, VP), Acc, Rest) ->
        Coeff is Coeff1 + Coeff2,
        somma_monomi_simili(T, [m(Coeff, TD, VP) | Rest], Result)
    ; somma_monomi_simili(T, [m(Coeff1, TD, VP) | Acc], Result)
    ).




% Valutazione di un polinomio
mvp_val(poly(Monomials), VariableValues, Value) :-
    maplist(monomial_val(VariableValues), Monomials, Values),!,
    ssum_list(Values, Value).

% Valutazione di un monomio
monomial_val(VariableValues, m(Coeff, _, Vars), Value) :-
    maplist(variable_val(VariableValues), Vars, VarValues),
    product_list(VarValues, Product),
    Value is Coeff * Product.

% Trovare il valore di una variabile dalla lista di valori
variable_val(VariableValues, v(Exponent, Var), Value) :-
    member((Var, VarValue), VariableValues),
    Value is VarValue ** Exponent.

% Prodotto di una lista di numeri
product_list(List, Product) :-
    foldl(multiply, List, 1, Product).

multiply(X, Y, Z) :- Z is X * Y.
