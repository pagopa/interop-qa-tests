@producer_listing
Feature: Listing e-services lato erogatore
  Tutti gli utenti autenticati di enti erogatori possono ottenere la lista dei propri e-service erogati

  @producer_listing1
  Scenario Outline: Restituisce gli e-service erogati dall’ente
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato 5 e-services in catalogo in stato PUBLISHED o SUSPENDED e 1 in stato DRAFT
    Given un "admin" di "PA2" ha già creato 5 e-services in catalogo in stato PUBLISHED o SUSPENDED e 1 in stato DRAFT
    When l'utente richiede una operazione di listing sui propri e-services erogati
    Then si ottiene status code 200 e la lista di <risultati> e-services

    Examples: 
      | ente | ruolo        | risultati |
      | GSP  | admin        |     6     |
      | GSP  | api          |     6     |
      | GSP  | security     |     5     |
      | GSP  | api,security |     6     |
      | GSP  | support      |     5     |
      | PA1  | admin        |     6     |
      | PA1  | api          |     6     |
      | PA1  | security     |     5     |
      | PA1  | api,security |     6     |
      | PA1  | support      |     5     |

  @producer_listing2
  Scenario Outline: A fronte di 20 e-service in db, restituisce solo i primi 12 risultati di e-service
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 19 e-services in catalogo in stato PUBLISHED o SUSPENDED e 1 in stato DRAFT
    When l'utente richiede una operazione di listing sui propri e-services erogati limitata ai primi 12 e-services
    Then si ottiene status code 200 e la lista di 12 e-services

  @producer_listing3
  Scenario Outline: A fronte di 15 e-service in db e una richiesta di offset 12, restituisce solo 3 risultati
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 14 e-services in catalogo in stato PUBLISHED o SUSPENDED e 1 in stato DRAFT
    When l'utente richiede una operazione di listing sui propri e-services con offset 12
    Then si ottiene status code 200 e la lista di 3 e-services

  @producer_listing4 @wait-for-fix
  Scenario Outline: Restituisce gli e-service erogati dall’ente fruiti da almeno uno dei fruitori specifici
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 2 e-services in catalogo in stato PUBLISHED o SUSPENDED e 1 in stato DRAFT
    Given "PA1" ha un agreement attivo con un e-service di "PA1"
    Given "PA2" ha un agreement attivo con un e-service di "PA1"
    When l'utente richiede una operazione di listing sui propri e-services fruiti da "PA2"
    Then si ottiene status code 200 e la lista di 1 e-services

  @producer_listing5
  Scenario Outline: Restituisce gli e-service erogati dall’ente che contengono la keyword "test" all'interno del nome, con ricerca case insensitive
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 2 e-services in catalogo in stato PUBLISHED o SUSPENDED e 1 in stato DRAFT
    Given un "admin" di "PA1" ha già creato e pubblicato un e-service contenente la keyword "test"
    When l'utente richiede una operazione di listing sui propri e-services filtrando per la keyword "test"
    Then si ottiene status code 200 e la lista di 1 e-services

  @producer_listing6
  Scenario Outline: Restituisce un insieme vuoto di e-service a catalogo per una ricerca che non porta risultati
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 10 e-services in catalogo in stato PUBLISHED o SUSPENDED e 1 in stato DRAFT
    When l'utente richiede una operazione di listing sui propri e-services filtrando per la keyword "unknown"
    Then si ottiene status code 200 e la lista di 0 e-services
