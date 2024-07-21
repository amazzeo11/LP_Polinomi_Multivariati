Mazzeo	Alessia	899612



- Libreria di predicati per la manipolazione di polinomi multivariati -

La seguente descrizione dei predicati implementati ricalca l'ordine fornito
nella traccia.
Per ogni funzione principale descritta vengono anche indicati i predicati 
di supporto che utilizza. 



Strutture di base:

Variabili:  v(Exp, Var)
Dove Exp è l'esponente associato al simbolo di variabile Var

Monomi:	 m(C, D, [V1, V2, …])
Dove:
- C è il coefficiente del monomio
- D è il grado totale del monomio
- V1, V2, … sono variabili nella forma sopra esposta

Polinomi:  poly([M1, M2, …])
Dove M1, M2, … sono monomi nella forma sopra specificata.

Nelle descrizioni seguenti si assume che polinomi e monomi abbiano sempre
la struttura sopra indicata, a meno di diversa indicazione.

Predicati forniti:
- is_monomial/1: è vero se l'argomento passato in input è un monomio nella
forma sopra descritta. Rispetto all'implementazione fornita è stato aggiunto
un ulteriore controllo sulla validità delle variabili presenti nella lista 
VPs utilizzando il predicato is_varpower/1 descritto di seguito.

-is_polinomial/1: è vero se l'argomento passato in input è un polinomio nella
forma sopra descritta. Effettua un controllo di validità su ogni monomio 
utilizzando il predicato is_monomial/1 sopra descritto.

-is_varpower/1: è vero se l'argomento passato in input è una variabile nella
forma sopra descritta.

Predicati implementati:

1) is_zero/1:
Il predicato is_zero(X) controlla che il polinomio o il monomio passati in 
input siano una rappresentazione dello 0.
Sono intese come rappresentazioni dello zero:
- il numero 0
- la lista vuota
- i monomi nella forma m(0,0,[])
- i polinomi nella forma poly([])
- i polinomi contenenti solo monomi nella forma m(0,0,[])
  ad esempio poly([m(0,0,[]), m(0,0,[]), m(0,0,[])]).


2) coefficients/2:
Il predicato coefficients(Poly, Coefficients) è vero quando Coefficients
è una lista contente i coefficienti di ogni monomio di Poly.
Si avvale del predicato ausiliario extract_coeff/2 che estrae i coefficienti
e li concatena in una lista.


3) variables/2:
Il predicato variables(Poly, Variables) è vero quando Variables
è una lista contente le variabili presenti in Poly, una sola occorrrenza
per simbolo di variabile.
Si avvale dei predicati di supporto extract_v, e variables_list per 
estrarre le variabili e concatenarle in una lista unica, dalla quale
vengono rimossi i duplicati.


4) monomials/2:
Il predicato monomials(Poly, Monomials) è vero quando Monomials
è una lista contente i monomi che compongono Poly.


5) max_degree/2:
Il predicato max_degree(Poly, Degree) è vero quando Degree è il
grado massimo dei monomi presenti in Poly.
Riordina in maniera decrescente i monomi ed estrae il grado del primo.


6) min_degree/2:
Il predicato min_degree(Poly, Degree) è vero quando Degree è il
grado minimo dei monomi presenti in Poly.
Si avvale del fatto che un polinomio parsato con la funzione
as_polynomial/2 ha i monomi ordinati in modo crescente rispetto al grado,
per cui estrae il grado del primo monomio di Poly.


7) mvp_plus/3:
Il predicato mvp_plus(Poly1, Poly2, Result) è vero quando Result è il
polinomio somma di Poly1 e Poly2.
Unisce i due polinomi in un'unica lista e somma i monomi 
di pari grado grazie alla funzione di supporto sum_ms/2 e sum_m/4.
Una volta effettuata la somma rimuove i monomi con coefficiente uguale a 0
utilizzando la funzione di supporto remove_zeros/2.


8) mvp_minus/3:
Il predicato mvp_minus(Poly1, Poly2, Result) è vero quando Result è il
polinomio differenza di Poly1 e Poly2.
Inverte i segni dei coefficienti di tutti i monomi del secondo polinomio 
con l'utilizzo della funzione di supporto reverse_s/2 e unisce i due polinomi
in un'unica lista. A questo punto effettua la somma dei due polinomi 
come spora esposto. 


9) mvp_times/3:
Il predicato mvp_times(Poly1, Poly2, Result) è vero quando Result è il
polinomio risultante dalla moltiplicazione di Poly1 e Poly2.
Per completezza implementativa sono stati gestiti i casi di:
- Polinomio * Polinomio (richiesta originale)
- Polinomio * Monomio
- Monomio * Polinomio
- Monomio * Monomio
Il predicato gestisce la somma tra polinomi creando una lista contenente
i prodotti tra monomi richiamando se stessa. I monomi simili vengono
sommati grazie al predicato ausiliario sum_like_m/2, e successivamente
vengono rimossi i monomi con coefficiente 0 mediante l'uso di exclude/3
e zero_coeff/1.
La moltiplicazione tra monomi restituisce a sua volta un monomio, formato
dalla moltiplicazione dei coefficienti, la somma dei gradi totali, e la
combinazione delle variabili effettuata con comb_var/2.
Il polinomio prodotto viene infine ordinato come successivamente
descritto nel predicato as_polynomial/2.


10) as_monomial/2:
Il predicato as_monomial(Expression, Monomial) è vero quando Monomial è il 
monomio risultante dal parsing dell’espressione Expression.
Il predicato si suddivide in 3 clausole che gestiscono i seguenti casi:
- coefficiente negativo 
- coefficiente esplicito 
- coefficiente non esplicito 

Se il coefficiente non è esplicito viene posto uguale a 1.
Se siamo in presenza di coefficiente negativo, esplicito o implicito,
il monomio viene parsato come se avesse coefficiente positivo, ma il suo
coefficiente viene poi negato.
Se il coefficiente è invece esplicito viene estratto mediante il predicato
first_sybol/2, che è utilizzato anche per differenziare i casi sopra esposti
andando a verificare la natura del simbolo estratto (integer se abbiamo 
coefficiente esplicito e non integer altrimenti).
Il grado totale del monomio e le sue variabili sono parsate grazie ai
predicati ausiliari total_degree/2 e var_powers/2. Infine la lista di 
variabili del monomio viene ordinata in modo crescente seguendo l'ordine
lessicografico delle variabili.
Total_degree/2 si avvale dei predicati ausiliari decompose_m/2, che scompone
il monomio in singoli termini, extract_exp/2 che ne estrae gli esponenti, e
ssum_list/2 che li somma per ottenere il grado complessivo.
Var_powers/2 si avvale anch'esso di decompose_m/2, e per ogni elemento 
richiama il predicato convert_vp/2 che converte ogni termine  che lo necessita
in una coppia base esponente. Se il termine è una potenza ne estrae base ed
esponente, se è un atomico non integer l'esponente viene posto a 1.


11) as_polynomial/2:
Il predicato as_polynomial(Expression, Polynomial) è vero quando Polynomial
è il polinomio risultante dal parsing dell’espressione Expression.
Scompone l'espressione in singoli termini che costituiscono i monomi mediante
il predicato ausiliario decompose_p/2. Tale predicato esamina i simboli + e -
presenti nell'espressione e ne deduce due espressioni, sulle quali viene 
richiamato ricorsivamente il predicato e vengono inserite in una lista di 
termini. Nel caso in cui le due espressioni siano separate dal simbolo -
i termini della seconda espressione vengono negati mediante negate_terms/2.
Una volta separati i monomi questi vengono parsati con as_monomial/2 come
sopra esposto. Infine i monomi parsati vengono ordinati in modo crescente per
grado, con spareggi in base alle variabili grazie a predsort e al predicato 
ausiliario in argomento compare_monomials/3.


12) mvp_val/3:
Il predicato mvp_val(Polynomial, VariableValues, Value) è vero quanto Value
contiene il valore del polinomio Polynomial nel punto n-dimensionale 
indicato dalla lista VariableValues, che contiene coppie variabile-valore.
Il predicato ausiliario monomial_val/3 viene mappato su tutta la lista di
monomi del polinomio fornito. Per ogni monomio vengono sostituiti i valori 
alle variabili e valutato il loro valore grazie a variable_val/3. I valori
ottenuti vengono moltiplicati tra loro utilizzando product_list/2 ed infine 
moltiplicati per il coefficiente.
Una volta elaborati i monomi, i valori ottenuti dalla valutazione vengono 
sommati con ssum_list/2, per ottenere il valore complessivo del polinomio.


13) pprint_polynomial/1:
Il predicato pprint_polynomial(Polynomial), è vero quando stampa sullo 
standard output il polinomio Polynomial in forma tradizionale.
La lista di monomi di Polynomial viene convertita in una lista di termini
sotto forma di stringhe, applicando il predicato ausiliario m_to_string/2
ad ogni monomio.
Tale predicato analizza separatamente i casi di monomi con coefficiente
positivo e negativo, per separarli correttamente nel polinomio risultante.
Coefficienti e variabili vengono gestiti rispettivamente da c_to_string/2
e v_to string/2. Una volta riconvertiti i monomi in forma tradizionale
vengono concatenati e stampati.