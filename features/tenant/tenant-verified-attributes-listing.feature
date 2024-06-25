@tenant-verified-attributes-listing
Feature: Listing attributi verificati posseduti da uno specifico ente
  Tutti gli utenti autenticati possono leggere la lista degli attributi verificati posseduti da uno specifico ente

  @tenant-verified-attributes-listing1a
  Scenario Outline: Per un attributo precedentemente verificato da un altro aderente, alla richiesta di lettura, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede una operazione di listing degli attributi verificati posseduti da "GSP"
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
    
  @tenant-verified-attributes-listing1b
  Scenario Outline: Per un attributo precedentemente verificato da un altro aderente, alla richiesta di lettura, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA1" crea un attributo verificato
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "AUTOMATIC"
    Given "GSP" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given "PA1" verifica l'attributo verificato a "GSP"
    When l'utente richiede una operazione di listing degli attributi verificati posseduti da "GSP"
    Then si ottiene status code 200 e la lista degli attributi contenente l'attributo verificato da "PA1"
