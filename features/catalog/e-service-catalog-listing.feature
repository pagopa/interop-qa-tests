@catalog
Feature: Listing catalogo e-services
  Tutti gli utenti autenticati di enti PA, GSP e privati possono ottenere la lista di e-services
 
  @catalog1
  Scenario Outline: Restituisce gli e-service a catalogo
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "GSP" ha già creato 10 e-services in catalogo in stato Published o Suspended
    When l'utente richiede una operazione di listing sul catalogo
    Then si ottiene status code "<risultato>" e la lista di 10 e-services

    Examples: 
      | ente           | ruolo | risultato |
      | GSP            | admin |       200 |
      # | ComuneDiMilano | admin |       200 |
      # | AgID           | admin |       200 |
      # | Privato        | admin |       200 |

  Scenario Outline: Un utente richiede la lista degli eservices di uno specifico erogatore
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "ComuneDiMilano" ha già creato più di 12 e-services in catalogo in stato Published o Suspended
    Given un "admin" di "AgID" ha già creato più di 12 e-services in catalogo in stato Published o Suspended
    When l'utente richiede una operazione di listing limitata ai primi 12 e-services dell'erogatore "ComuneDiMilano"
    Then si ottiene status code "<risultato>" e la lista degli eservices dell'erogatore specificato
   # Then si ottiene status code <risultato> e la lista di 1 risultati

    Examples: 
      | ente           | ruolo | risultato |
      | GSP            | admin |       200 |
      | ComuneDiMilano | admin |       200 |
      | AgID           | admin |       200 |
      | Privato        | admin |       200 |

  @agreement
  Scenario Outline: Un utente richiede la lista di eservices per i quali ha almeno un agreement attivo
    Given l'utente è un "<ruolo>" di "<ente_fruitore>"
    Given un "admin" di "ComuneDiMilano" ha già creato più di 12 e-services in catalogo in stato Published o Suspended
    And   ente_fruitore ha già richiesto l'approvazione dell'agreement per un eservice di "ComuneDiMilano"
    And   un "admin" di "ComuneDiMilano" ha già approvato la richiesta di agreement di ente_fruitore
    When l'utente richiede la lista di eservices per i quali ha almeno un agreement attivo
    Then si ottiene status code <risultato> e la lista di 1 risultati

    Examples: 
      | ente_fruitore   | ruolo | risultato |
      | GSP             | admin |       200 |
      | AgID            | admin |       200 |
      | Privato         | admin |       200 |


  @agreement_service_suspended
  Scenario Outline: Un utente richiede la lista di eservices di cui almeno uno sospeso di uno specifico erogatore per i quali ha almeno un agreement attivo
    Given l'utente è un "<ruolo>" di "<ente_fruitore>"
    Given un "admin" di "ComuneDiMilano" ha già creato più di 12 e-services in catalogo in stato Published o Suspended
    And   ente_fruitore ha già richiesto l'approvazione dell'agreement per un eservice di "ComuneDiMilano"
    And   un "admin" di "ComuneDiMilano" ha già approvato la richiesta di agreement di ente_fruitore
    And   un "admin" di "ComuneDiMilano" ha già sospeso la versione dell'eservice che ente_fruitore ha sottoscritto

    Given un "admin" di "GSP" ha già creato più di 12 e-services in catalogo in stato Published o Suspended
    And   ente_fruitore ha già richiesto l'approvazione dell'agreement per un eservice di "GSP"
    And   un "admin" di "GSP" ha già approvato la richiesta di agreement di ente_fruitore
    And   un "admin" di "GSP" ha già sospeso la versione dell'eservice che ente_fruitore ha sottoscritto


    Given un "admin" di "AgID" ha già creato più di 12 e-services in catalogo in stato Published o Suspended
    And   ente_fruitore ha già richiesto l'approvazione dell'agreement per un eservice di "AgID"
    And   un "admin" di "AgID" ha già approvato la richiesta di agreement di ente_fruitore
    And   un "admin" di "AgID" ha già sospeso la versione dell'eservice che ente_fruitore ha sottoscritto

    When l'utente richiede la lista di eservices che hanno almeno una versione in stato SUSPENDED, erogati da "ComuneDiMilano" e "AgID" per i quali ha almeno un agreement attivo che contengono la keyword di ricerca
    Then si ottiene status code <risultato> e la lista di 2 e-services

    Examples: 
      | ente_fruitore       | ruolo | risultato |
      | Privato             | admin |       200 |