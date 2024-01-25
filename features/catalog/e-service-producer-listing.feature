@producer_listing
Feature: Listing e-services lato erogatore
  Tutti gli utenti autenticati di enti erogatori possono ottenere la lista dei propri e-service erogati

  @producer_listing1
  Scenario Outline: Restituisce gli e-service erogati dall’ente
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato 5 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    Given un "admin" di "PA2" ha già creato 5 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    When l'utente richiede una operazione di listing sui propri e-services erogati
    Then si ottiene status code 200 e la lista di 6 e-services

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |
 
  @producer_listing2
  Scenario Outline: A fronte di 20 e-service in db, restituisce solo i primi 12 risultati di e-service
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "GSP" ha già creato 19 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    When l'utente richiede una operazione di listing sui propri e-services erogati limitata ai primi 12 e-services
    Then si ottiene status code 200 e la lista di 12 e-services

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |
      | PA2            | admin |

  @producer_listing3
  Scenario Outline: A fronte di 15 e-service in db e una richiesta di offset 12, restituisce solo 3 risultati
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "GSP" ha già creato 14 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    When l'utente richiede una operazione di listing sui propri e-services con offset 12
    Then si ottiene status code 200 e la lista di 3 e-services

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |
      | PA2            | admin |
      

  @producer_listing4
  Scenario Outline: Restituisce gli e-service erogati dall’ente fruiti da almeno uno degli fruitori specifici
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato 2 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    Given "GSP" ha un agreement attivo con e-service di "<ente>"
    Given "PA2" ha un agreement attivo con e-service di "<ente>"
    When l'utente richiede una operazione di listing sui propri e-services fruiti da "GSP"
    Then si ottiene status code 200 e la lista di 1 e-services

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |
      | PA2            | admin |

  @producer_listing5
  Scenario Outline: Restituisce gli e-service erogati dall’ente che contengono la keyword "test" all'interno del nome, con ricerca case insensitive
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato 2 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    Given un "<ruolo>" di "<ente>" ha già creato e pubblicato un e-service contenente la keyword "test"
    When l'utente richiede una operazione di listing sui propri e-services filtrando per la keyword "test"
    Then si ottiene status code 200 e la lista di 1 e-services

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |
      | PA2            | admin |

  @producer_listing5
  Scenario Outline: Restituisce un insieme vuoto di e-service a catalogo per una ricerca che non porta risultati
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato 10 e-services in catalogo in stato Published o Suspended e 1 in stato Draft
    When l'utente richiede una operazione di listing sui propri e-services filtrando per la keyword "unknown"
    Then si ottiene status code 200 e la lista di 0 e-services

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |
      | PA2            | admin |
