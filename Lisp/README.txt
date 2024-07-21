Mazzeo	Alessia	899612



- Libreria di predicati per la manipolazione di polinomi multivariati -

La seguente descrizione dei predicati implementati ricalca l'ordine fornito
nella traccia.
Per ogni funzione principale descritta vengono anche indicati i predicati 
di supporto che utilizza. 



Strutture di base:

Variabili:  (v power var-symbol)
Dove power è l'esponente associato al simbolo di variabile var-symbol

Monomi:	 (m coefficient total-degree vars-n-powers)
Dove:
- coefficient è il coefficiente del monomio
- total-degree è il grado totale del monomio
- vars-n-power sono variabili nella forma sopra esposta

Polinomi:  (poly monomials)
Dove monomials sono monomi nella forma sopra specificata.

Nelle funzioni seguenti sono stati implementati controlli sulla struttura
dei monomi e polinomi passati in input, se vengono passati in forma 
tradizionale e non come appena descritto vengono parsati mediante
le funzioni as_monomial/1 e as_polynomial/1. Tale concetto verrà dato per
scontato nelle seguenti descrizioni al fine di evitare eccessive ripetizioni.


Predicati forniti:
- is_monomial/1: controlla che l'espressione data in input sia un 
monomio nella forma sopra descritta. Controlla la validità delle 
variabili utilizzando la funzione is_varpower/1 descritta in seguito.

-is_polinomial/1: controlla che l'espressione data in input sia un polinomio
nella forma sopra descritta. Effettua un controllo di validità su ogni monomio 
utilizzando la funzione is_monomial/1 sopra descritta.

-is_varpower/1: controlla che l'espressione data in input sia una variabile 
nella forma sopra descritta.

Predicati implementati:

1) is_zero/1:
La funzione is-zero X → Result ritorna T come Result, quando X è una 
rappresentazione dello 0.
Sono intese come rappresentazioni dello zero:
- il numero 0
- i monomi nella forma (m 0 0 ())
- i polinomi nella forma (poly ())
- i polinomi contenenti solo monomi nella forma (m 0 0 ())


2) var-powers/1:
La funzione var-powers Monomial → VP-list data una struttura Monomial, 
ritorna la lista di varpowers VP-list, estraendo il quarto elemento del
monomio dato in input. Per compleezza impemenativa è stata gestita 
l'estrazione delle variabili anche da un polinomio. Se non viene
trovata una lista di variabili valida la funzione restituisce nil.


3) vars-of/1:
La funzione vars-of Monomial → Variables data una struttura Monomial,
ritorna la lista di variabili Variables. 
Dal monomio viene estratta la lista di variabili mediante var-powers/1,
e da ognuna viene estratto il simbolo di funzione, il quale viene 
concatenato in una lista appiattita.
Una volta elaborata tale lista vengono rimossi i duplicati.


4) monomial-degree/1:
La funzione monomial-degree Monomial → TotalDegree data una struttura
Monomial, ritorna il suo grado totale TotalDegree estraendo il terzo
elemento presente nel monomio.
Se il grado rilevato ha un valore sensato viene restituito, altrimenti
viene restituito nil. Se viene passato in input un polinomio viene 
restituito nil poiché viene richiesto di gestire esclusivamente i monomi.


5) monomial-coefficient/1:
La funzione monomial-coefficient Monomial → Coefficient data una struttura 
Monomial, ritorna il suo coefficiente Coefficient, estraendolo dal secondo
elemento presente nel monomio.
Se il coefficiente ha un valore sensato viene restituito, altrimenti viene
restituito nil. Se il monomio è nullo viene restituito 0.


6) coefficients/1:
La funzione coefficients Poly → Coefficients dato in input un polinomio 
ritorna una lista Coefficients dei coefficienti dei monomi presenti in Poly.
I monomi vengono estratti da Poly mediante monomials/1, se la lista è nulla 
viene restituito 0, altrimenti viene invocata la funzione 
monomial-coefficient/1 su ogni monomio, e viene creata una lista contenente 
tutti i coefficienti estratti.


7) variables/1:
La funzione variables Poly → Variables dato in input un polinomio
ritorna una lista Variables dei simboli di variabile che appaiono in Poly.
I monomi vengono estratti da Poly mediante monomials/1 (descritta in seguito),
per ciascun monomio viene invocata var-powers/1 per estrarre la lista delle 
variabili presenti, che vengono inserite in un'unica lista appiattita.
Vengono poi estratti i simboli di variabile con la funzione varpower-symbol/1,
e vengono rimossi i duplicati.


8) monomials/1:
La funzione monomials Poly → Monomials dato in input un polinomio
ritorna la lista ordinata dei monomi che appaiono in Poly, estraendola dal 
polinomio escludendo il primo elemento "poly".


9) max-degree/1:
La funzione max-degree Poly → Degree dato in input un polinomio, ritorna il
massimo grado dei monomi che appaiono in Poly.
Per farlo estrae i monomi da Poly con la funzione monomials/1, e seleziona
l'ultimo della lista. A questo punto estrae il suo coefficiente utilizzando 
monomial-degree/1.


10) min-degree/1:
La funzione min-degree Poly → Degree dato in input un polinomio, ritorna il
 minimo grado dei monomi che appaiono in Poly. 
Per farlo estrae i monomi da Poly con la funzione monomials/1, e seleziona
il primo della lista. A questo punto estrae il suo coefficiente utilizzando
monomial-degree/1.


11) mvp-plus/2:
La funzione mvp-plus Poly1 Poly2 → Result presi in input due polinomi produce
il polinomio somma Result di Poly1 e Poly2. 
I monomi vengono estratti dai due polinomi con la funzione monomials/1, 
dopodichè vengono concatenati in un'unica lista.
Tale lista viene ordinata per avere monomi simili adiacenti, così che vengano 
combinati sommando i coefficienti con la funzione sum-like-m/1.
Infine vengono rimossi i monomi con coefficiente 0 dalla lista
risultante


12) mvp-minus/2:
La funzione mvp-minus Poly1 Poly2 → Result presi in input due polinomi produce
il polinomio differenza Result di Poly1 e Poly2.
Il procedimento della funzione è speculare a mvp-sum, ma i monomi di Poly2 
vengono elaborati con la funzione reverse-s/1 che ne cambia il segno dei 
coefficienti.


13) mvp-times/2:
La funzione mvp-times Poly1 Poly2 → Result presi in input due polinomi produce
il polinomio Result risultante dalla moltiplicazione di Poly1 e Poly2.
I monomi vengono estratti dai due polinomi con la funzione monomials/1, e 
vengono moltiplicati grazie alla funzione mvp-t/2. Tale funzione ausiliaria
moltiplica ricorsivamente il primo monomio del primo polinomio con tutti i
monomi del secondo, e ripete per ogni monomio del primo. Per effettuare la 
moltiplicazione tra polinomi viene chiamata la funzione ausiliaria mul-m/2
che a sua volta utilizza mul-v/2 per la moltiplicazione delle variabili.
La lista risultante dal procedimento appena descritto viene poi ripulita
eliminando i termini con coefficiente 0 con remove-zero/1, semplificata
utilizzando la funzione sum-like-m/1 e ordinata utilizzando sort-p/1.
La funzione mvp-times gestisce i casi di moltiplicazione tra:
- polinomio e polinomio
- monomio e polinomio
- polinomio e monomio
- monomio e monomio


14) as-monomial/1:
La funzione as-monomial Expression → Monomial data in input un'espressione
ritorna la struttura dati (lista) che rappresenta il monomio risultante dal
parsing dell’espressione Expression, con le variabili in ordine lesicografico
crescente.
L'epressioe viene parsata dalla funzione ausiliaria as-ms/1 che 
produce un risultato intermedio da ordinare con sort-m/1, e da semplificare
con la funzione reduce-m/1.
As-ms/1 gestisce 3 casistiche:
- Expression è un numero -> ritorna un monomio numerico con grado uguale a 0
  e lista di variabili vuota
- Expression è un simbolo atomico -> lo considera come una variabile con grado
  1 e coefficiente 1
- Altro -> elabora il monomio tramite funzioni ausiliarie
Le funzioni ausiliarie utili alla gestione di quest'ultimo caso sono 
raggruppate sotto la sezione "funzioni ausiliarie per as-monomial" all'interno 
del codice. Di particolare interesse è la funzione sort-m/1 che copia la lista
delle variabili ottenute da var-powers/1 e utilizza stable-sort per ordinarla
secondo il criterio richiesto e fornito da order-d/1.


15) as-polynomial/1:
La funzione as-polynomial Expression → Polynomial data in input un'espressione
ritorna la struttura dati (lista) che rappresenta il polinomio risultante dal
parsing dell’espressione Expression con i monomi ordinati per grado in modo 
crescente e spareggi dati dalle variabili.
L'espressione viene esaminata, se è un monomio viene parsato con la funzione 
parse-p/1 che trasforma direttamente il monomio in polinomio. Altrimenti 
viene parsata da as-pe, che converte l'espressione in una lista di monomi
usando il predicato as-monomial/1 sopra descritto. Una volta ottenuta la lista
di monomi questa viene semplificata, ripulita ed ordinata con le funzioni 
ausiliarie remove-zero/1, sum-like-m/1 e sort-p/1 che si occupa 
dell'ordinamento richiesto per i monomi.


16) mvp-val/2:
La funzione mvp-val Polynomial VariableValues → Value dato in input un 
polinomio restituisce il valore Value del polinomio Polynomial nel punto
n-dimensionale rappresentato dalla lista VariableValues, lista che contiene
un valore per ogni variabile ottenuta con la funzione variables/1.
Una volta ottenuto l'elenco delle variabili presenti in p tramite variables/1
con pairlis/2 viene generata una lista di coppie variabile valore con i valori
contenuti in VariableValues. Dopodiché il valore del polinomio viene calcolato
grazie alla funzione eval-p/2 che prende in input la a-list generata e il 
polinomio fornito. Eval-p estrae tutti i termini di Polynomial e per ognuno
applica eval-term/2 per calcolarne il valore. Tale funzione sfrutta le
associazioni descritte per calcolare il valore della variabile elevata al suo
esponente, e moltiplica tra loro i valori ottenuti. Il risultato viene quindi
moltiplicato per il coefficiente. Elaborati i singoli termini questi vengono
combinati utilizzando reduce per sommare i valori ed ottenere il valore 
finale del polinomio.


17) pprint-polynomial/1:
La funzione  pprint-polynomial Polynomial → NIL dato in input un polinomio
ritorna NIL dopo aver stampato sullo standard output una rappresentazione 
tradizionale del termine polinomio associato a Polynomial.
La funzione utilizza la funzione ausiliaria pprint-pe/1 che si occupa di
formattare i singoli termini di Polynomial invocando pprint-pc/1 per ogni
termine. Quest'ultima formatta ogni termine individuale gestendo i 
coefficienti e chiamando pprint-pv/1 per la formattazione delle variabili.
