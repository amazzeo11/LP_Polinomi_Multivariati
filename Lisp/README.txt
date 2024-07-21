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
ritorna la lista di variabili Variables. Dal monomio viene estratta la
lista di variabili mediante var-powers/1, e da ognuna viene estratto
il simbolo di funzione, il quale viene concatenato in una lista appiattita.
Una volta elaborata tale lista vengono rimossi i duplicati.

4) monomial-degree/1:
 Function monomial-degree Monomial → TotalDegree
 Data una struttura Monomial, ritorna il suo grado totale TotalDegree.

5) monomial-coefficient/1:
Function monomial-coefficient Monomial → Coefficient
 Data una struttura Monomial, ritorna il suo coefficiente Coefficient.

6)Function coefficients Poly → Coefficients
 La funzione coefficients ritorna una lista Coefficients dei– ovviamente– coefficienti di Poly.

7)Function variables Poly → Variables
 La funzione variables ritorna una lista Variables dei simboli di variabile che appaiono in Poly.

8)Function monomials Poly → Monomials
 La funzione monomials ritorna la lista– ordinata, si veda sotto– dei monomi che appaiono in Poly.

9)Function max-degree Poly → Degree
 La funzione max-degree ritorna il massimo grado dei monomi che appaiono in Poly.

10)Function min-degree Poly → Degree
 La funzione min-degree ritorna il minimo grado dei monomi che appaiono in Poly.

11)Function mvp-plus Poly1 Poly2 → Result
 La funzione mvp-plus produce il polinomio somma di Poly1 e Poly2.

12)Function mvp-minus Poly1 Poly2 → Result
 La funzione mvp-minus produce il polinomio differenza di Poly1 e Poly2.

13)Function mvp-times Poly1 Poly2 → Result
 La funzione mvp-times ritorna il polinomio risultante dalla moltiplicazione di Poly1 e Poly2.

14)Function as-monomial Expression → Monomial
 La funzione as-monomial ritorna la struttura dati (lista) che rappresenta il monomio risultante dal
 “parsing” dell’espressione Expression; il monomio risultante deve essere appropriatamente ordinato (si
 veda sotto)

15) Function as-polynomial Expression → Polynomial
 La funzione as-polynomial ritorna la struttura dati (lista) che rappresenta il monomio risultante dal
 “parsing” dell’espressione Expression; il polinomio risultante deve essere appropriatamente ordinato (si
 veda sotto).

16)Function mvp-val Polynomial VariableValues → Value
 La funzione mvp-val restituisce il valore Value del polinomio Polynomial (che può anche essere un
 monomio), nel punto n-dimensionale rappresentato dalla lista VariableValues, che contiene un valore
 per ogni variabile ottenuta con la funzione variables.

17) Function pprint-polynomial Polynomial → NIL
 La funzione pprint-polynomial ritorna NIL dopo aver stampato (sullo “standard output”) una rapp
resentazione tradizionale del termine polinomio associato a Polynomial.
