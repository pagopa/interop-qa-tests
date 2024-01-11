@catalog_consumers
Feature: Listing di enti che fruiscono del mio e-service
  Tutti gli utenti autenticati di enti PA, GSP che erogano gli e-services possono ottenere la lista dei fruitori che ne usufruiscono

  @catalog_consumers1
  Scenario Outline: Restituisce i fruitori di uno specifico e-service che il mio ente eroga
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    Given  "PA2" ha un agreement attivo con un eservice di "<ente>"
    Given  "Privato" ha un agreement attivo con un eservice di "<ente>"
    When l'utente richiede una lista dei fruitori dell'e-service creato # TODO
    Then si ottiene status code 200 e la lista di 2 fruitori # TODO

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |

  @catalog_consumers2
  Scenario Outline: Restituisce un insieme vuoto di fruitori di uno specifico e-service che il mio ente eroga che non ha fruitori
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    When l'utente richiede una lista dei fruitori dell'e-service creato
    Then si ottiene status code 200 e la lista di 0 fruitori

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |

