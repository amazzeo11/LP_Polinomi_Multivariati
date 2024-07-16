Mazzeo	Alessia	899612

La seguente descizione dei predicati implementati segue l'ordine fornito nella traccia.
Per ogni funzione principale descritta vengono anche indicati i nomi delle funzioni di supporto che utilizza, i nomi di queste ultime sono in inglese per mantenere la coerenza implementativa con le funzioni principali.
Infine sono indicate alcune funzioni implementate per gestire dei casi considerati ma non esplicitati nella traccia, oppure per incoerenze tracci.


variabili:
v(Exp, Var)

Dove Exp è l'esponente associato al simbolo di variabile Var


monomi:
m(C,D,[V1, V2, …])

Dove:
- C è il coefficiente del monomio
- D è il grado totale del monomio
- V1, V2, … sono variabili nella forma sopra indicata


polinomi:
poly([M1, M2, …])
dove M1, M2, … sono monomi nella forma sopra specificata.


Nelle descrizioni seguenti si assume che polinomi e monomi abbiano sempre
la struttura sopra indicata, a meno di diversa indicazione.

1)is_zero/1:

il predicato is_zero(X) controlla che il polinomio o il monomio passati in 
input siano una rappresentazione dello 0.
Sono intese come rappresentazioni dello zero:
- i monomi nella forma m(0,0,[])
- i polinomi nella forma poly([])
- i polinomi contenenti solo monomi nella forma m(0,0,[])
ad esempio poly([m(0,0,[]), m(0,0,[]), m(0,0,[])]).


2)coefficients/2:
prende in input un polinomio nella forma poly([monomials]) ed estrae
i coefficienti di ogni monomio con la funzione di supporto extract_coeff/2.
I monomi sono da intendersi nella forma m(C,D,V).


3)variables/2:


4)monomials/2:


5)max_degree/2:


6)min_degree/2:


7)mvp_plus/3:


8)mvp_minus/3:


9)mvp_times/3:


10)as_monomial/2:


11)as_polynomial/2:


12)mvp_val/3:


13)pprint_polynomial/1: