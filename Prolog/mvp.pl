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

as_monomial(E, _) :-
    %coefficiente
    first_symbol(E,C),

    write(C)
   % integer(C),
    %C is [C],
   % append(M, C, M)
    %totalDegree
   % sum_exp(V, _)
    .

% Base case: if E is a number or an atom, the first symbol is E itself.
first_symbol(E, [E]) :-
    (number(E); atom(E)), !.

% Recursive case: if E is a compound term, extract the first argument.
first_symbol(E, Symbol) :-
    E =.. [_ | Args],  % Decompose the term into functor and arguments
    Args = [FirstArg | _],   % Get the first argument
    first_symbol(FirstArg, Symbol).  % Recursively find the first symbol

%sum_exp(M, T):-

