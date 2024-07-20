

%%% is_monomial/1:
%%% monomi in forma: m(Coefficient, TotalDegree, VarsPowers)

is_monomial(m(_C, TD, VPs)) :-
    integer(TD),
    TD >= 0,
    is_list(VPs),
    foreach(member(V, VPs), is_varpower(V)).



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
is_zero(0):-!.
is_zero([]):- !.

is_zero(X) :-
    is_monomial(X),
    X = m(0, 0, []),
    !.

is_zero(m(C, _, _)) :-
 C =:= 0.

is_zero(poly([])):- !.

is_zero(X) :-
    is_polynomial(X),
    X = poly(M),
    foreach(member(Y, M), is_zero(Y)).

%%% as_polynomial/2:
as_polynomial(E, poly(P)) :-
    decompose_p(E, M),
    maplist(as_monomial, M, Ps),
    predsort(compare_monomials, Ps, P),!.


compare_monomials(Order, m(_, G1, V1), m(_, G2, V2)) :-
    ( G1 < G2 ->
        Order = <
    ; G1 > G2 ->
        Order = >
    ; compare_variables(V1, V2, Order)
    ).

compare_variables([], [], =).
compare_variables([v(D1, V1)|T1], [v(D2, V2)|T2], Order) :-
    ( V1 @< V2 ->
        Order = <
    ; V1 @> V2 ->
        Order = >
    ; D1 < D2 ->
        Order = <
    ; D1 > D2 ->
        Order = >
    ; compare_variables(T1, T2, Order)
    ).
compare_variables([], [_|_], <).
compare_variables([_|_], [], >).



%%% decompose_p/2:
decompose_p(E1+E2, Terms) :-
    decompose_p(E1, Terms1),
    decompose_p(E2, Terms2),!,
    append(Terms1, Terms2, Terms).

decompose_p(E1-E2, Terms) :-
    decompose_p(E1, Terms1),
    decompose_p(E2, Terms2),
    negate_terms(Terms2, NegatedTerms2),!,
    append(Terms1, NegatedTerms2, Terms).

decompose_p(E, [E]).

%%% negate_terms/2:
negate_terms([], []).
negate_terms([E|Es], [NE|NEs]) :-
    negate_term(E, NE),
    negate_terms(Es, NEs).

%%% negate_term/2:
negate_term(E, -E) :-
    \+ functor(E, -, 1), !.
negate_term(-E, E) :- !.
negate_term(E, -E).




as_monomial(-E, m(C, T, V)) :-
    as_monomial(E, m(PositiveC, T, V)),!,
    C is -PositiveC.

%%% as_monomial/2:
as_monomial(E, m(C, T, V)) :-
    first_symbol(E, S),
    integer(S),
    C is S,
    total_degree(E, TotalDegree),
    !,
    T is TotalDegree,
    var_powers(E, Vs),
    sort(2, @=<, Vs, Vps),
    V = Vps.


as_monomial(E, m(C, T, V)) :-
    first_symbol(E, S),
    \+ integer(S),
    C is 1,
    total_degree(E, TotalDegree),
    !,
    T is TotalDegree,
    var_powers(E, Vs),
    sort(2, @=<, Vs, Vps),
    V = Vps.



first_symbol(E, E) :-
    (number(E); atom(E)), !.

first_symbol(E, Symbol) :-
    E =.. [_ | Args],
    Args = [First | _],
    first_symbol(First, Symbol).

total_degree(E, TotalDegree) :-
    decompose_m(E, Terms),
    extract_exp(Terms, Exp),
    ssum_list(Exp, TotalDegree).

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
    \+ integer(T).

convert_vp(T, null) :-
    T =.. [_ | _].


%%%pprint_polynomial/1
pprint_polynomial(poly(M)) :-
    maplist(m_to_string, M, Terms),
    atomic_list_concat(Terms, '', P),
    writeln(P).

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


c_to_string(C, '') :- C =:= 1, !.
c_to_string(C, Cs) :-
    number_string(C, Cs).

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


%%%monomials/2:
monomials(poly(P), P).


%%%min_degree/2:
min_degree(poly([m(_,D,_)|_]), D).

%%%max_degree/2:
max_degree(poly(P), D):- sort(2,@>=,P,Ps), Ps = [m(_,D,_)|_].


monomials_t(P,M):-
    decompose_p(P,Ms),
    sort(1,@<,Ms,M).

%%%variables/2:
variables_list(poly(P),V) :-
    maplist(extract_v, P, Ps),
    flatten(Ps,V).

extract_v(m(_,_,V), Vs) :-
    append([],V,Vs).

variables(poly(P),V) :-
    variables_list(poly(P),Vs),
    maplist(arg(2), Vs, D),
    list_to_set(D,V).

%%%mvp_plus/3:
mvp_plus(poly(M1), poly(M2), poly(Result)) :-
    append(M1, M2, Ms),
    sum_ms(Ms, Mc),
    !,
    remove_zeros(Mc, Result),
    !.

sum_ms([], []) :- !.
sum_ms([m(C, TD, VP) | T], [m(CS, TD, VP) | R]) :-
    sum_m(m(C, TD, VP), T, CS, T1),
    sum_ms(T1, R),
    !.

sum_m(m(C, _, _), [], C, []) :- !.
sum_m(m(C, TD, VP), [m(C1, TD, VP) | T], CS, R) :-
    CS1 is C + C1,
    sum_m(m(CS1, TD, VP), T, CS, R),
    !.
sum_m(M, [H | T], CS, [H | R]) :-
    sum_m(M, T, CS, R),
    !.

remove_zeros([], []) :- !.
remove_zeros([m(0, _, _) | T], R) :-
    remove_zeros(T, R),
    !.

remove_zeros([H | T], [H | R]) :-
    remove_zeros(T, R),
    !.

reverse_s([], []) :- !.
reverse_s([m(C, TD, VP) | T], [m(CNeg, TD, VP) | T1]) :-
    CNeg is -C,
    reverse_s(T, T1),
    !.

%%%mvp_minus/3:
mvp_minus(poly(M1), poly(M2), poly(Result)) :-
    reverse_s(M2, M2Neg),
    append(M1, M2Neg, MT),
    sum_ms(MT, MC),
    !,
    remove_zeros(MC, Result),
    !.






%%%mvp_times/3:
mvp_times(poly(Ms1), poly(Ms2), poly(Rs)) :-
    findall(m(Coeff, TD, VP),
            (member(M1, Ms1), member(M2, Ms2),
             mvp_times(M1, M2, m(Coeff, TD, VP))),
            MP),
    !,
    sum_like_m(MP, MS),
    exclude(zero_coeff, MS, R),
    predsort(compare_monomials, R, Rs),
    !.

mvp_times(poly(Ms1), M, poly(Rs)) :-
    findall(m(C, TD, VP),
            (member(M1, Ms1),
             mvp_times(M1, M, m(C, TD, VP))),
            MP),
    !,
    sum_like_m(MP, MS),
    exclude(zero_coeff, MS, R),
    predsort(compare_monomials, R, Rs),
    !.

mvp_times(M, poly(Ms2), poly(Rs)) :-
    findall(m(C, TD, VP),
            (member(M2, Ms2),
             mvp_times(M, M2, m(C, TD, VP))),
            MP),
    !,
    sum_like_m(MP, MS),
    exclude(zero_coeff, MS, R),
    predsort(compare_monomials, R, Rs),
    !.


mvp_times(m(C1, TD1, VP1), m(C2, TD2, VP2), m(C, TD, VP)) :-
    C is C1 * C2,
    TD is TD1 + TD2,
    append(VP1, VP2, VPs),
    comb_var(VPs, VP).


comb_var(VPList, R) :-
    comb_var(VPList, [], R).

comb_var([], Acc, Acc).
comb_var([v(D1, X) | T], Acc, R) :-
    ( select(v(D2, X), Acc, Rest) ->
        D is D1 + D2,
        comb_var(T, [v(D, X) | Rest], R)
    ; comb_var(T, [v(D1, X) | Acc], R)
    ).


sum_like_m(M, R) :-
    sort_m(M, MOrd),
    sum_like_m(MOrd, [], R).

sum_like_m([], Acc, Acc).

sum_like_m([m(C1, TD, VP) | T], Acc, R) :-
    ( select(m(C2, TD, VP), Acc, Rest) ->
        C is C1 + C2,
        sum_like_m(T, [m(C, TD, VP) | Rest], R)
    ; sum_like_m(T, [m(C1, TD, VP) | Acc], R)
    ).


zero_coeff(m(C, _, _)) :- C =:= 0.

sort_m([], []).
sort_m([m(C, TD, VP) | T], [m(C, TD, SVP) | ST]) :-
    sort(2,@=<,VP,SVP),
    sort_m(T, ST).



%%%mvp_val/3:
mvp_val(poly(Ms), Vals, V) :-
    is_polynomial(poly(Ms)),
    maplist(monomial_val(Vals), Ms, Values),
    ssum_list(Values, V).

monomial_val(Vals, m(C, _, Vars), V) :-
    maplist(variable_val(Vals), Vars, VarValues),!,
    product_list(VarValues, P),
    V is C * P.

variable_val(Vals, v(E, Var), V) :-
    member((Var, VarValue), Vals),
    V is VarValue ** E.

product_list(L, P) :-
    foldl(multiply, L, 1, P).

multiply(X, Y, Z) :- Z is X * Y.
