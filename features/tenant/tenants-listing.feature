@tenants-listing
Feature: Listing degli aderenti
  Tutti gli utenti autenticati possono leggere la lista dei aderenti

  @tenants-listing1
  Scenario Outline: A fronte di 3 aderenti in db, restituisce solo i primi 2 risultati (scopo del test è verificare il corretto funzionamento del parametro limit)
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede una operazione di listing degli aderenti limitata a 2
    Then si ottiene status code "<statusCode>" e la lista di 2 aderenti

    Examples:
      | ente    | ruolo        | statusCode |
      | GSP     | admin        |        200 |
      | GSP     | api          |        200 |
      | GSP     | security     |        200 |
      | GSP     | api,security |        200 |
      | GSP     | support      |        200 |
      | PA1     | api          |        200 |
      | PA1     | admin        |        200 |
      | PA1     | security     |        200 |
      | PA1     | support      |        200 |
      | PA1     | api,security |        200 |
      | Privato | admin        |        400 |
      | Privato | api          |        400 |
      | Privato | security     |        400 |
      | Privato | support      |        400 |
      | Privato | api,security |        400 |

    @tenants-listing2
  Scenario Outline: Restituisce gli aderenti che contengono la keyword "comune" all'interno del nome, con ricerca case insensitive (scopo del test è verificare che funzioni il filtro name)
    Given l'utente è un "admin" di "PA1"
    When l'utente richiede una operazione di listing degli aderenti filtrando per la keyword "comune"
    Then si ottiene status code 200 e la lista di 1 aderente

    @tenants-listing3
  Scenario Outline: Restituisce un insieme vuoto di aderenti per una ricerca che non porta risultati (scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)
    Given l'utente è un "admin" di "PA1"
    When l'utente richiede una operazione di listing degli aderenti senza ricevere risultato 
    Then si ottiene status code 200 e la lista di 0 aderenti