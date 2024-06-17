
@tenant-e-service-producers-listing
Feature: Listing e-service producers
  Tutti gli utenti autenticati possono leggere la lista dei aderenti che erogano almeno un e-service

  @tenant-e-service-producers-listing1
  Scenario Outline: Restituisce tutti gli erogatori di e-service presenti in catalogo per qualsiasi livello di permesso e tipologia di ente. NB: probabilmente vengono presi anche gli e-service che non sono ancora stati pubblicati a catalogo (hanno una versione sola in stato DRAFT); verificare se è questo il caso; in caso va bene se è più facile per il backend e aggiorniamo il test
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    When l'utente richiede una operazione di listing degli erogatori
    # controllare in implementazione
    Then si ottiene status code 200 e la lista di erogatori contenente "<ente>"

    Examples: 
      | ente    | ruolo        |
      | GSP     | admin        |
      | GSP     | api          |
      | GSP     | security     |
      | GSP     | support      |
      | GSP     | api,security |
      | PA1     | admin        |
      | PA1     | api          |
      | PA1     | security     |
      | PA1     | support      |
      | PA1     | api,security |
      | Privato | admin        |
      | Privato | api          |
      | Privato | security     |
      | Privato | support      |
      | Privato | api,security |

  @tenant-e-service-producers-listing2
  Scenario Outline: A fronte di 4 o più aderenti in db, restituisce solo i primi 2 risultati (scopo del test è verificare il corretto funzionamento del parametro limit)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "GSP" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    When l'utente richiede una operazione di listing degli erogatori con limit 2
    Then si ottiene status code 200 e la lista di 2 aderenti

  @tenant-e-service-producers-listing3
  Scenario Outline: A fronte di 4 o più aderenti in db e una richiesta di offset 12, restituisce solo 3 risultati (scopo del test è verificare il corretto funzionamento del parametro offset)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "GSP" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    When l'utente richiede una operazione di listing degli erogatori con offset 2
    Then si ottiene status code 200 e il giusto numero di risultati in base all'offset richiesto

  @tenant-e-service-producers-listing4
  Scenario Outline: Restituisce gli aderenti che contengono la keyword "PagoPA" all'interno del nome, con ricerca case insensitive (scopo del test è verificare che funzioni il filtro q)
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    When l'utente richiede una operazione di listing degli erogatori filtrando per nome aderente "PagoPA"
    Then si ottiene status code 200 e la lista di 1 aderente

  @tenant-e-service-producers-listing5
  Scenario Outline: Restituisce un insieme vuoto di aderenti per una ricerca che non porta risultati (scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)
    Given l'utente è un "admin" di "PA1"
    When l'utente richiede una operazione di listing degli erogatori filtrando per nome aderente "unknown"
    Then si ottiene status code 200 e la lista di 0 aderenti
