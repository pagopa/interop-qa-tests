@tenant-declared-attributes-listing
Feature: Listing attributi dichiarati posseduti da uno specifico ente
  Tutti gli utenti autenticati possono leggere la lista degli attributi dichiarati posseduti da uno specifico ente

  @tenant-declared-attributes-listing1a
  Scenario Outline: Per un attributo precedentemente dichiarato dall’aderente stesso, alla richiesta di lettura, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede una operazione di listing degli attributi dichiarati posseduti da "GSP"
    Then si ottiene status code 200 

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
    
  @tenant-declared-attributes-listing1b
  Scenario Outline: Per un attributo precedentemente dichiarato dall’aderente stesso, alla richiesta di lettura, va a buon fine
    Given l'utente è un "admin" di "PA2"
    Given "PA1" dichiara un attributo dichiarato
    When l'utente richiede una operazione di listing degli attributi dichiarati posseduti da "PA1"
    Then si ottiene status code 200 e la lista degli attributi contenente l'attributo dichiarato
