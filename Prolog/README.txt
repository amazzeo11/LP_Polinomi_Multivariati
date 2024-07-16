Mazzeo	Alessia	899612

La seguente descrizione dei predicati implementati ricalca l'ordine fornito
nella traccia.
Per ogni funzione principale descritta vengono anche indicati i nomi delle 
funzioni di supporto che utilizza. I nomi di queste ultime sono in inglese
per mantenere la coerenza implementativa con le funzioni principali.
Infine sono indicate alcune funzioni extra implementate durante lo sviluppo 
del progetto al fine di coprire alcune ambiguità e gestire casi particolari.


Strutture di base:

Variabili:  v(Exp, Var)
Dove Exp è l'esponente associato al simbolo di variabile Var


Monomi:	 m(C,D,[V1, V2, …])
Dove:
- C è il coefficiente del monomio
- D è il grado totale del monomio
- V1, V2, … sono variabili nella forma sopra esposta


Polinomi:  poly([M1, M2, …])
Dove M1, M2, … sono monomi nella forma sopra specificata.


Nelle descrizioni seguenti si assume che polinomi e monomi abbiano sempre
la struttura sopra indicata, a meno di diversa indicazione.


Predicati:

1) is_zero/1:

il predicato is_zero(X) controlla che il polinomio o il monomio passati in 
input siano una rappresentazione dello 0.
Sono intese come rappresentazioni dello zero:
- i monomi nella forma m(0,0,[])
- i polinomi nella forma poly([])
- i polinomi contenenti solo monomi nella forma m(0,0,[])
ad esempio poly([m(0,0,[]), m(0,0,[]), m(0,0,[])]).


2) coefficients/2:
prende in input un polinomio e restituisce una lista contente i
coefficienti di ogni monomio, avvalendosi della funzione di 
supporto extract_coeff/2 che estrae i coefficienti e li 
concatena in una lista.


3) variables/2:
prende in input un polinomio e restituisce la lista delle
variabili contenute in ogni monomio, avvalendosi della
funzione di supporto extract_v che estrae le variabili
e le concatena in una lista.
E' stata implementata anche una funzione supplementare
only_variables, vedasi la fine del file.


4) monomials/2:
prende in input un polinomio e restituisce la lista dei
monomi che lo compongono.
E' stata implementata anche una funzione supplementare
monomials_t, vedasi la fine del file.


5) max_degree/2:
prende in input un polinomio e restituisce il grado massimo dei
monomi che lo compongono, riordinando in maniera decrescente i
monomi ed estraendo il grado del primo.

6) min_degree/2:
prende in input un polinomio e restituisce il grado del primo monomio
presente avvalendosi del fatto che un polinomio parsato con la funzione
as_polynomial ha i monomi ordinati in modo crescente rispetto al grado.


7) mvp_plus/3:


8) mvp_minus/3:


9) mvp_times/3:


10) as_monomial/2:


11) as_polynomial/2:


12) mvp_val/3:


13) pprint_polynomial/1:



funzioni extra:
- only_variables/2: prende in input un polinomio e restituisce
una lista contenente una sola occorrenza di ogni simbolo di variabile
presente.


- monomials_t/2:
prende in input un polinomio in forma tradizionale e restituisce i 
monomi che lo compongono in forma tradizionale