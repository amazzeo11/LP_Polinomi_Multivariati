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

%%%caso in cui il coefficiente del monomio non è esplicito
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
    maplist(as_monomial, M, Ps),
    sort(2,@=<,Ps,P).%%%ricontrolla sorting


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

% Regola per il caso base: il termine è un monomio
decompose_p(E, [E]) :-
    E =.. [_ | _],
    !.

% Regola per il caso base: il termine è una costante
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
    atomic_list_concat(Terms, ' + ', P),
    writeln(P).

% Conversione di un monomio in una stringa
m_to_string(m(C, _, V), Term) :-
    c_to_string(C, Cs),
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
    flatten(Ps,Vs),
    maplist(arg(2), Vs, D),
    list_to_set(D,V).

extract_v(m(_,_,V), Vs) :-
    append([],V,Vs).


% Predicato principale
mvp_plus(poly(Monomi1), poly(Monomi2), poly(Result)) :-
    append(Monomi1, Monomi2, MonomiTotali),
    somma_monomi(MonomiTotali, MonomiCombinati),!,
    rimuovi_zeri(MonomiCombinati, Result).

% Somma monomi con lo stesso TotalDegree e VarPowers
somma_monomi([], []).
somma_monomi([m(Coeff, TD, VP) | T], [m(CoeffS, TD, VP) | R]) :-
    somma_monomio(m(Coeff, TD, VP), T, CoeffS, T1),
    somma_monomi(T1, R).

% Somma un singolo monomio con quelli uguali nella lista
somma_monomio(m(Coeff, _, _), [], Coeff, []).
somma_monomio(m(Coeff, TD, VP), [m(Coeff1, TD, VP) | T], CoeffS, R) :-
    CoeffS1 is Coeff + Coeff1,
    somma_monomio(m(CoeffS1, TD, VP), T, CoeffS, R).
somma_monomio(M, [H | T], CoeffS, [H | R]) :-
    somma_monomio(M, T, CoeffS, R).

% Rimuovi monomi con coefficiente zero
rimuovi_zeri([], []).
rimuovi_zeri([m(0, _, _) | T], R) :-
    rimuovi_zeri(T, R).
rimuovi_zeri([H | T], [H | R]) :-
    rimuovi_zeri(T, R).


% Predicato principale per la sottrazione
mvp_minus(poly(Monomi1), poly(Monomi2), poly(Result)) :-
    inverti_segni(Monomi2, Monomi2Neg),
    append(Monomi1, Monomi2Neg, MonomiTotali),
    somma_monomi(MonomiTotali, MonomiCombinati),!,
    rimuovi_zeri(MonomiCombinati, Result),!.

% Inverti i segni dei coefficienti dei monomi
inverti_segni([], []).
inverti_segni([m(Coeff, TD, VP) | T], [m(CoeffNeg, TD, VP) | T1]) :-
    CoeffNeg is -Coeff,
    inverti_segni(T, T1).






