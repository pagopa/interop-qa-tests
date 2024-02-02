@catalog_listing
Feature: Listing catalogo e-services
  Tutti gli utenti autenticati di enti PA, GSP e privati possono ottenere la lista di e-services
 
  @catalog_listing1
  Scenario Outline: Restituisce gli e-service a catalogo
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA1" ha già creato 5 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    When l'utente richiede una operazione di listing sul catalogo
    Then si ottiene status code 200 e la lista di 5 e-services

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

  @catalog_listing2
  Scenario Outline: A fronte di 20 e-service in db e una richiesta di 12 e-service, restituisce solo i primi 12 risultati
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 19 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    When l'utente richiede una operazione di listing sul catalogo limitata ai primi 12 e-services
    Then si ottiene status code 200 e la lista di 12 e-services

  @catalog_listing3
  Scenario Outline: A fronte di 15 e-service in db e una richiesta di risultati a partire dal tredicesimo, vengono restituiti solo 3 e-service
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 15 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    When l'utente richiede una operazione di listing sul catalogo con offset 12
    Then si ottiene status code 200 e la lista di 3 e-services

  @catalog_listing4
  Scenario Outline: Restituisce gli e-service a catalogo erogati da almeno uno degli erogatori specifici
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato 2 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    Given un "admin" di "GSP" ha già creato 2 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    When l'utente richiede una operazione di listing degli e-services dell'erogatore "PA2"
    Then si ottiene status code 200 e la lista di 2 e-services

  @catalog_listing5
  Scenario Outline: Restituisce gli e-service a catalogo per i quali lo specifico fruitore ha almeno un agreement in stato ACTIVE
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato 3 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    And "PA1" ha un agreement attivo con un e-service di "PA2"
    When l'utente richiede la lista di eservices per i quali ha almeno un agreement attivo
    Then si ottiene status code 200 e la lista di 1 e-services

  @catalog_listing6
  Scenario Outline: Restituisce gli e-service a catalogo che contengono la keyword "test" all'interno del nome, 
  con ricerca case insensitive

    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 2 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    Given un "admin" di "PA1" ha già creato e pubblicato un e-service contenente la keyword "test"
    When l'utente richiede una operazione di listing sul catalogo filtrando per la keyword "test"
    Then si ottiene status code 200 e la lista di 1 e-services

  @catalog_listing7
  Scenario Outline: Restituisce un insieme vuoto di e-service a catalogo per una ricerca che non porta risultati
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato 10 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    When l'utente richiede una operazione di listing sul catalogo filtrando per la keyword "unknown"
    Then si ottiene status code 200 e la lista di 0 e-services
