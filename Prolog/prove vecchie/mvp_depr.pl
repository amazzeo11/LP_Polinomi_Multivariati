%%%Mazzeo Alessia 899612



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
variables(poly(P),V) :-
    maplist(extract_v, P, Ps),
    flatten(Ps,V).

extract_v(m(_,_,V), Vs) :-
    append([],V,Vs).

only_variables(poly(P),V) :-
    variables(poly(P),Vs),
    maplist(arg(2), Vs, D),
    list_to_set(D,V).

%%%mvp_plus/3:
mvp_plus(poly(M1), poly(M2), poly(Result)) :-
    append(M1, M2, Ms),
    sum_ms(Ms, Mc),!,
    remove_zeros(Mc, Result).

sum_ms([], []).
sum_ms([m(C, TD, VP) | T], [m(CS, TD, VP) | R]) :-
    sum_m(m(C, TD, VP), T, CS, T1),
    sum_ms(T1, R).

sum_m(m(C, _, _), [], C, []).
sum_m(m(C, TD, VP), [m(C1, TD, VP) | T], CS, R) :-
    CS1 is C + C1,
    sum_m(m(CS1, TD, VP), T, CS, R).
sum_m(M, [H | T], CS, [H | R]) :-
    sum_m(M, T, CS, R).

remove_zeros([], []).
remove_zeros([m(0, _, _) | T], R) :-
    remove_zeros(T, R).
remove_zeros([H | T], [H | R]) :-
    remove_zeros(T, R).


%%%mvp_minus/3:
mvp_minus(poly(M1), poly(M2), poly(Result)) :-
    reverse_s(M2, M2Neg),
    append(M1, M2Neg, MT),
    sum_ms(MT, MC),!,
    remove_zeros(MC, Result),!.

reverse_s([], []).
reverse_s([m(C, TD, VP) | T], [m(CNeg, TD, VP) | T1]) :-
    CNeg is -C,
    reverse_s(T, T1).





%%%mvp_times/3:
mvp_times(poly(Monomi1), poly(Monomi2), poly(Result_sorted)) :-
    findall(m(Coeff, TD, VP),
            (member(M1, Monomi1), member(M2, Monomi2),
             mvp_times(M1, M2, m(Coeff, TD, VP))),
            MonomiProdotti),!,
    sum_like_m(MonomiProdotti, MonomiSommati),
    exclude(zero_coeff, MonomiSommati, Result),
     predsort(compare_monomials, Result, Result_sorted).


mvp_times(poly(Monomi1), Monomio, poly(Result_sorted)) :-
    findall(m(Coeff, TD, VP),
            (member(M1, Monomi1),
             mvp_times(M1, Monomio, m(Coeff, TD, VP))),
            MonomiProdotti),!,
    sum_like_m(MonomiProdotti, MonomiSommati),
    exclude(zero_coeff, MonomiSommati, Result),
    predsort(compare_monomials, Result, Result_sorted).

mvp_times(Monomio, poly(Monomi2), poly(Result_sorted)) :-
    findall(m(Coeff, TD, VP),
            (member(M2, Monomi2),
             mvp_times(Monomio, M2, m(Coeff, TD, VP))),
            MonomiProdotti),!,
    sum_like_m(MonomiProdotti, MonomiSommati),
    exclude(zero_coeff, MonomiSommati, Result),
    predsort(compare_monomials, Result, Result_sorted).


mvp_times(m(C1, TD1, VP1), m(C2, TD2, VP2), m(C, TD, VP)) :-
    C is C1 * C2,
    TD is TD1 + TD2,
    append(VP1, VP2, VPs),
    comb_var(VPs, VP).

moltiplica_monomi([], _, []).
moltiplica_monomi([m(C1, TD1, VP1) | T], m(C2, TD2, VP2), [m(C, TD, VP) | R]) :-
    C is C1 * C2,
    TD is TD1 + TD2,
    append(VP1, VP2, VPList),
    comb_var(VPList, VP),
    moltiplica_monomi(T, m(C2, TD2, VP2), R).

comb_var(VPList, Result) :-
    comb_var(VPList, [], Result).

comb_var([], Acc, Acc).
comb_var([v(D1, X) | T], Acc, Result) :-
    ( select(v(D2, X), Acc, Rest) ->
        D is D1 + D2,
        comb_var(T, [v(D, X) | Rest], Result)
    ; comb_var(T, [v(D1, X) | Acc], Result)
    ).


sum_like_m(Monomi, Result) :-
    sort_m(Monomi, MonomiOrdinati),
    sum_like_m(MonomiOrdinati, [], Result).
sum_like_m([], Acc, Acc).
sum_like_m([m(Coeff1, TD, VP) | T], Acc, Result) :-
    ( select(m(Coeff2, TD, VP), Acc, Rest) ->
        Coeff is Coeff1 + Coeff2,
        sum_like_m(T, [m(Coeff, TD, VP) | Rest], Result)
    ; sum_like_m(T, [m(Coeff1, TD, VP) | Acc], Result)
    ).


zero_coeff(m(C, _, _)) :- C =:= 0.

sort_m([], []).
sort_m([m(C, TD, VP) | T], [m(C, TD, SVP) | ST]) :-
    sort(2,@=<,VP,SVP),
    sort_m(T, ST).



%%%mvp_val/3:
mvp_val(poly(Monomials), VariableValues, Value) :-
    is_polynomial(poly(Monomials)),
    maplist(monomial_val(VariableValues), Monomials, Values),
    ssum_list(Values, Value).

monomial_val(VariableValues, m(Coeff, _, Vars), Value) :-
    maplist(variable_val(VariableValues), Vars, VarValues),!,
    product_list(VarValues, Product),
    Value is Coeff * Product.

variable_val(VariableValues, v(Exponent, Var), Value) :-
    member((Var, VarValue), VariableValues),
    Value is VarValue ** Exponent.

product_list(List, Product) :-
    foldl(multiply, List, 1, Product).

multiply(X, Y, Z) :- Z is X * Y.

