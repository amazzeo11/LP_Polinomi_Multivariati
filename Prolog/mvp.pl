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

%as_monomial(E, M) :-

    %coefficiente
   % first_symbol(E,C),
   % integer(C),
   % M is m(C),
  %  write(M)
       %totalDegree
   % sum_exp(V, _)
  %  .

 %  as_monomial(E, m(C,T,V)):-
 %    first_symbol(E,S),
  %  integer(S),
 %   C is S,
  %  grado_totale(E, S),
 %   T is S,
  %  V is 0.

% Base case: if E is a number or an atom, the first symbol is E itself.
first_symbol(E, E) :-
    (number(E); atom(E)), !.

% Recursive case: if E is a compound term, extract the first argument.
first_symbol(E, Symbol) :-
    E =.. [_ | Args],  % Decompose the term into functor and arguments
    Args = [FirstArg | _],   % Get the first argument
    first_symbol(FirstArg, Symbol).  % Recursively find the first symbol

% Predicato principale che calcola il grado totale di un monomio.
grado_totale(Term, GradoTotale) :-
    scomponi(Term, Termini),
    estrai_esponenti(Termini, Esponenti),
    somma_lista(Esponenti, GradoTotale).

% Scompone il monomio nei suoi termini costituenti.
scomponi(Term, [Term]) :-
    atomic(Term),
    !.
scomponi(Term, Termini) :-
    Term =.. [*, Term1, Term2],
    scomponi(Term1, Termini1),
    scomponi(Term2, Termini2),
    append(Termini1, Termini2, Termini).
scomponi(Term, [Term]) :-
    Term =.. [_ | _].

% Estrae gli esponenti delle variabili dai termini.
estrai_esponenti([], []).
estrai_esponenti([Term | Rest], [1 | Esponenti]) :-
    atomic(Term),
    \+ integer(Term),
    !,
    estrai_esponenti(Rest, Esponenti).
estrai_esponenti([_^Exp | Rest], [Exp | Esponenti]) :-
    !,
    estrai_esponenti(Rest, Esponenti).
estrai_esponenti([_ | Rest], Esponenti) :-
    estrai_esponenti(Rest, Esponenti).

% Predicato per sommare gli elementi di una lista.
somma_lista([], 0).
somma_lista([H | T], Somma) :-
    somma_lista(T, Rest),
    Somma is H + Rest.

% Predicato principale per la conversione di un'espressione in monomio.
as_monomial(E, m(C, T, V)) :-
    first_symbol(E, S),
    integer(S),
    C is S,
    grado_totale(E, GradoTotale),
    T is GradoTotale,
    V is 0.


