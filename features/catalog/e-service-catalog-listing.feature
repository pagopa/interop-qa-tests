@catalog
Feature: Listing catalogo e-services
  Tutti gli utenti autenticati di enti PA, GSP e privati possono ottenere la lista di e-services
 
  @catalog1
  Scenario Outline: Restituisce gli e-service a catalogo
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "GSP" ha già creato 5 e-services in catalogo in stato Published o Suspended
    When l'utente richiede una operazione di listing sul catalogo
    Then si ottiene status code <risultato> e la lista di 5 e-services

    Examples: 
      | ente           | ruolo | risultato |
      | GSP            | admin |       200 |
      # | PA1 | admin |       200 |
      # | PA2           | admin |       200 |
      # | Privato        | admin |       200 |

  @catalog2
  Scenario Outline: A fronte di 20 e-service in db, restituisce solo i primi 12 risultati di e-service
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "GSP" ha già creato 20 e-services in catalogo in stato Published o Suspended
    When l'utente richiede una operazione di listing sul catalogo limitata ai primi 12 e-services
    Then si ottiene status code <risultato> e la lista di 12 e-services

    Examples: 
      | ente           | ruolo | risultato |
      | GSP            | admin |       200 |
      # | PA1 | admin |       200 |
      # | PA2           | admin |       200 |
      # | Privato        | admin |       200 |

  @catalog3
  Scenario Outline: A fronte di 15 e-service in db e una richiesta di offset 12, restituisce solo 3 risultati
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "GSP" ha già creato 15 e-services in catalogo in stato Published o Suspended
    When l'utente richiede una operazione di listing sul catalogo con offset 12
    Then si ottiene status code <risultato> e la lista di 3 e-services

    Examples: 
      | ente           | ruolo | risultato |
      | GSP            | admin |       200 |
      # | PA1 | admin |       200 |
      # | PA2           | admin |       200 |
      # | Privato        | admin |       200 |

  @catalog4
  Scenario Outline: Restituisce gli e-service a catalogo erogati da almeno uno degli erogatori specifici
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA1" ha già creato 2 e-services in catalogo in stato Published o Suspended
    Given un "admin" di "PA2" ha già creato 2 e-services in catalogo in stato Published o Suspended
    When l'utente richiede una operazione di listing degli e-services dell'erogatore "PA1"
    Then si ottiene status code <risultato> e la lista di 2 e-services

    Examples: 
      | ente           | ruolo | risultato |
      | GSP            | admin |       200 |
      # | PA1 | admin |       200 |
      # | PA2           | admin |       200 |
      # | Privato        | admin |       200 |

  @catalog5
  Scenario Outline: Restituisce gli e-service a catalogo per i quali lo specifico fruitore ha almeno un agreement in stato ACTIVE
    Given l'utente è un "<ruolo>" di "<ente_fruitore>"
    Given un "admin" di "PA1" ha già creato 3 e-services in catalogo in stato Published o Suspended
    And   ente_fruitore ha un agreement attivo con un eservice di "PA1"
    When l'utente richiede la lista di eservices per i quali ha almeno un agreement attivo
    Then si ottiene status code <risultato> e la lista di 1 e-services

    Examples: 
      | ente_fruitore   | ruolo | risultato |
      | GSP             | admin |       200 |
      # | PA2            | admin |       200 |
      # | Privato         | admin |       200 |

  @catalog6
  Scenario Outline: Restituisce gli e-service a catalogo che contengono la keyword "test" all'interno del nome, 
  con ricerca case insensitive
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "GSP" ha già creato 2 e-services in catalogo in stato Published o Suspended
    Given un "admin" di "GSP" ha già creato un e-service contenente la keyword "test"
    When l'utente richiede una operazione di listing sul catalogo filtrando per la keyword "test"
    Then si ottiene status code <risultato> e la lista di 1 e-services

    Examples: 
      | ente           | ruolo | risultato |
      | GSP            | admin |       200 |
      # | PA1 | admin |       200 |
      # | PA2           | admin |       200 |
      # | Privato        | admin |       200 |

  @catalog7
  Scenario Outline: Restituisce un insieme vuoto di e-service a catalogo per una ricerca che non porta risultati
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "GSP" ha già creato 10 e-services in catalogo in stato Published o Suspended
    When l'utente richiede una operazione di listing sul catalogo filtrando per la keyword "unknown"
    Then si ottiene status code <risultato> e la lista di 0 e-services

    Examples: 
      | ente           | ruolo | risultato |
      | GSP            | admin |       200 |
      # | PA1 | admin |       200 |
      # | PA2           | admin |       200 |
      # | Privato        | admin |       200 |