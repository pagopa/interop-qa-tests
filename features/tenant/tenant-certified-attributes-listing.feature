@tenant-certified-attributes-listing
Feature: Listing attributi certificati posseduti da uno specifico aderente
  Tutti gli utenti autenticati possono leggere la lista degli attributi certificati posseduti da uno specifico aderente

  @tenant-certified-attributes-listing1a
  Scenario Outline: Per due attributi precedentemente assegnati all’aderente, uno assegnato dalla piattaforma e facente parte degli attributi previsti da IPA e uno assegnato da un altro aderente dal flusso attributi self-service, alla richiesta di lettura, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede una operazione di listing degli attributi certificati posseduti da "GSP"
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
    
  @tenant-certified-attributes-listing1b
  Scenario Outline: Per due attributi precedentemente assegnati all’aderente, uno assegnato dalla piattaforma e facente parte degli attributi previsti da IPA e uno assegnato da un altro aderente dal flusso attributi self-service, alla richiesta di lettura, va a buon fine
    Given l'utente è un "admin" di "PA2"
    Given "PA2" ha creato un attributo certificato e lo ha assegnato a "PA1"
    When l'utente richiede una operazione di listing degli attributi certificati posseduti da "PA1"
    Then si ottiene status code 200 e la lista degli attributi contenente l'attributo assegnato da "PA2" e l'attributo IPA comune
