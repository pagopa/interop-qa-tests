@descriptor_activation
Feature: Riattivazione di un descrittore
  Tutti gli utenti autorizzati di enti erogatori possono riattivare un descrittore in stato SUSPENDED

  @descriptor_activation1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato SUSPENDED, all'attivazione del descrittore, si ripubblica correttamente
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato "SUSPENDED"
    When l'utente riattiva il descrittore di quell'e-service
    Then si ottiene status code <risultato>

    Examples: 
    | ente               | ruolo          | risultato |
    | GSP                | admin          | 204       |
    | GSP                | api            | 204       |
    | GSP                | security       | 403       |
    | GSP                | api,security   | 204       |
    | GSP                | support        | 403       |
    | PA1                | admin          | 204       |
    | PA1                | api            | 204       |
    | PA1                | security       | 403       |
    | PA1                | api,security   | 204       |
    | PA1                | support        | 403       |
  
  @descriptor_activation2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale non si trova in stato SUSPENDED, alla riattivazione del descrittore, si ottiene un errore
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "GSP" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
    When l'utente riattiva il descrittore di quell'e-service
    Then si ottiene status code 400

    Examples: 
      | statoDescrittore |
      | ARCHIVED         |
      | DRAFT            |
      | DEPRECATED       |
      | PUBLISHED        |

