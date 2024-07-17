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
only_variables/2, vedasi la fine del file.


4) monomials/2:
prende in input un polinomio e restituisce la lista dei
monomi che lo compongono.
E' stata implementata anche una funzione supplementare
monomials_t/2, vedasi la fine del file.


5) max_degree/2:
prende in input un polinomio e restituisce il grado massimo dei
monomi che lo compongono, riordinando in maniera decrescente i
monomi ed estraendo il grado del primo.

6) min_degree/2:
prende in input un polinomio e restituisce il grado del primo monomio
presente avvalendosi del fatto che un polinomio parsato con la funzione
as_polynomial/2 ha i monomi ordinati in modo crescente rispetto al grado.


7) mvp_plus/3:
prende in input 2 polinomi e restituisce il polinomio derivante dalla somma
dei due. Per farlo unisce i due polinomi in un'unica lista e somma i monomi 
di pari grado grazie alla funzione di supporto sum_ms/2 e sum_m/4.
Una volta effettuata la somma rimuove i monomi con coefficiente uguale a 0
utilizzando la funzione di supporto remove_zeros/2.

8) mvp_minus/3:
prende in input 2 polinomi e restituisce il polinomio derivante dalla 
differenza dei due. Per farlo inverte i segni dei coefficienti di tutti i
monomi del secondo polinomio con l'utilizzo della funzione di supporto 
reverse_s e unisce i due polinomi in un'unica lista. A questo punto effettua
la somma dei due polinomi come spora esposto. 



9) mvp_times/3:


10) as_monomial/2:
prende in input un monomio in forma tradizionale e restituisce un monomio
in forma composta come esposto ad inizio file.
Il predicato si suddivide in 3 clausole che gestiscono i seguenti casi:
- coefficiente esplicito -> C prende il valore rilevato
- coefficiente non esplicito negativo -> C prende il valore di -1
- coefficiente non esplicito -> C prende il valore di -1

La prima parte della funzione si occupa di stabilire in quale caso ci 
troviamo verificando il primo simbolo del monomio con l'ausilio della
funzione di supporto first_symbol/2.
La restante parte della funzione è comune alle 3 clausole:
viene calcolato il grado totale del monomio con total_degree/2, vengono
estratte le variabili con l'ausilio di var_powers/2 e vengono ordinate
in modo crescente per esponente con spareggi determinati dalle variabili.
per analizzare gli esponenti delle variabili il monomio viene scomposto
in singoli termini grazie alla funzione decompose_m/2, e gli esponenti 
vengono estratti con extract_exp/2.



11) as_polynomial/2:


12) mvp_val/3:
prende in input un polinomio e una lista composta da coppie variabile-valore
utili alla sostituzione del valore alla variabile nel polinomio.
Il predicato mvp_val viene mappato su tutta la lista di monomi del polinomio
fornito. Per ogni monomio vengono sostituiti i valori alle variabili e viene
calcolato il valore risultante dalla moltiplicazione del coefficiente per le
variabili elevate ai loro esponenti. Per farlo vengono utilizzate le funzioni
di supporto variable_val/3 e product_list/2. Una volta elaborati i monomi i 
valori ottenuti vengono sommati con sum_list2/2, per ottenere il valore
complessivo del polinomio.


13) pprint_polynomial/1:



funzioni extra:
- only_variables/2: prende in input un polinomio e restituisce
una lista contenente una sola occorrenza di ogni simbolo di variabile
presente.


- monomials_t/2:
prende in input un polinomio in forma tradizionale e restituisce i 
monomi che lo compongono in forma tradizionale