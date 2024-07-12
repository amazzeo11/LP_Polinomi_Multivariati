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
    grado_totale(E, GradoTotale),
    !,
    T is GradoTotale,
    var_powers(E, Varpws),
    sort(1,@>=,Varpws,Vs),
    sort(2,@=<,Vs,Vps),
    V = Vps.

%%%caso in cui il coefficiente del monomio non � esplicito
as_monomial(E, m(C, T, V)) :-
    first_symbol(E, S),
    \+integer(S),
    C is 1,
    grado_totale(E, GradoTotale),
    !,
    T is GradoTotale,
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
    Args = [FirstArg | _],   % Get the first argument
    first_symbol(FirstArg, Symbol).  % Recursively find the first symbol



%%% grado totale/2:
%%% calcola il grado complessivo del monomio

grado_totale(E, GradoTotale) :-
    scomponi_m(E, Termini),
    estrai_esponenti(Termini, Esponenti),
    somma_lista(Esponenti, GradoTotale).


%%% scomponi/2:
%%% Scompone il monomio in termini singoli

scomponi_m(E, [E]) :-
    atomic(E),
    !.

scomponi_m(E, Termini) :-
    E =.. [*, T1, T2],
    scomponi_m(T1, Term1),
    scomponi_m(T2, Term2),
    !,
    append(Term1, Term2, Termini).

scomponi_m(E, [E]) :-
    E =.. [_ | _].


%%% estrai_esponenti/2:
%%% Estrae gli esponenti delle variabili dai singoli termini

estrai_esponenti([], []).
estrai_esponenti([E | Rest], [1 | Esponenti]) :-
    atomic(E),
    \+ integer(E),
    !,
    estrai_esponenti(Rest, Esponenti).

estrai_esponenti([_^Exp | Rest], [Exp | Esponenti]) :-
    !,
    estrai_esponenti(Rest, Esponenti).

estrai_esponenti([_ | Rest], Esponenti) :-
    estrai_esponenti(Rest, Esponenti).

%%% somma_lista/2:
%%% Calcola la somma degli elementi della lista

somma_lista([], 0).
somma_lista([H | T], Somma) :-
    somma_lista(T, Rest),
    Somma is H + Rest.


var_powers(E, V) :-
    scomponi_m(E, E1),
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
    scomponi_p(E,M),
    maplist(as_monomial, M, P).



scomponi_p(E, [E]) :-
    atomic(E),
    !.

scomponi_p(E, Termini) :-
    E =.. [+, T1, T2],
    scomponi_p(T1, Term1),
    scomponi_p(T2, Term2),
    !,
    append(Term1, Term2, Termini).

scomponi_p(E, Termini) :-
    E =.. [-, T1, T2],
    scomponi_p(T1, Term1),
    scomponi_p(T2, Term2),
    !,
    append(Term1, Term2, Termini).

