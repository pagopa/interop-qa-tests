@descriptor_suspension
Feature: Sospensione di un descrittore
  Tutti gli utenti autorizzati di enti erogatori possono sospendere i propri descrittori

  @descriptor_suspension1
  Scenario Outline: Per un e-service che ha un descrittore in stato PUBLISHED o DEPRECATED, alla richiesta di sospensione da parte di un utente autorizzato, la sospensione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente sospende quel descrittore
    Then si ottiene status code <risultato>

    Examples: 
      | ente           | ruolo        |      statoVersione | risultato |
      | GSP            | admin        |      PUBLISHED     | 204       |
      | GSP            | admin        |      DEPRECATED    | 204       |
      | GSP            | security     |      PUBLISHED     | 403       |
      | GSP            | security     |      DEPRECATED    | 403       |
      | GSP            | api,security |      PUBLISHED     | 204       |
      | GSP            | api,security |      DEPRECATED    | 204       |
      | GSP            | support      |      PUBLISHED     | 403       |
      | GSP            | support      |      DEPRECATED    | 403       |
      | PA1            | admin        |      PUBLISHED     | 204       |
      | PA1            | admin        |      DEPRECATED    | 204       |
      | PA1            | security     |      PUBLISHED     | 403       |
      | PA1            | security     |      DEPRECATED    | 403       |
      | PA1            | api,security |      PUBLISHED     | 204       |
      | PA1            | api,security |      DEPRECATED    | 204       |
      | PA1            | support      |      PUBLISHED     | 403       |
      | PA1            | support      |      DEPRECATED    | 403       |

 @descriptor_suspension2
  Scenario Outline: Per un e-service che ha un descrittore in stato ARCHIVED, DRAFT o SUSPENDED, alla richiesta di sospensione, si ottiene un errore 
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "GSP" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente sospende quel descrittore
    Then si ottiene status code 400

    Examples: 
      |      statoVersione |
      |      DRAFT         |
      |      SUSPENDED     |
      |      ARCHIVED      |
