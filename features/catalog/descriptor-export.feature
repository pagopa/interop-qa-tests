@descriptor_export
Feature: Export di un descrittore
  Tutti gli utenti autorizzati possono effettuare una richiesta di export di un descrittore di un e-service che il proprio ente eroga.

  @descriptor_export1
  Scenario Outline: La richiesta di export di un descrittore di un e-service, senza documenti, in stato NON DRAFT, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
    When l'utente effettua una richiesta di export del descrittore
    Then si ottiene status code 200
    And il pacchetto risulta correttamente formattato

    Examples:
      | ente | ruolo        | statoDescrittore |
      | GSP  | admin        | PUBLISHED        |
      | GSP  | api          | PUBLISHED        |
      | GSP  | security     | PUBLISHED        |
      | GSP  | api,security | PUBLISHED        |
      | GSP  | support      | PUBLISHED        |
      | PA1  | admin        | PUBLISHED        |
      | PA1  | api          | PUBLISHED        |
      | PA1  | security     | PUBLISHED        |
      | PA1  | api,security | PUBLISHED        |
      | PA1  | support      | PUBLISHED        |

    Examples:
      | ente | ruolo | statoDescrittore |
      | PA1  | admin | ARCHIVED         |
      | PA1  | admin | DEPRECATED       |
      | PA1  | admin | SUSPENDED        |

  @descriptor_export2
  Scenario Outline: La richiesta di export di un descrittore di un e-service, in stato DRAFT, ritorna un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente effettua una richiesta di export del descrittore
    Then si ottiene status code 400

  @descriptor_export3
  Scenario Outline: La richiesta di export di un descrittore di un e-service, senza documenti, da parte di un ente che non è l’erogatore, ritorna un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    When l'utente effettua una richiesta di export del descrittore
    Then si ottiene status code 403

  @descriptor_export4
  Scenario Outline: La richiesta di export di un descrittore di un e-service, senza documenti, in erogazione inversa, con un’analisi del rischio compilata, va a buon fine. Il documento di configurazione che è parte del pacchetto esportato contiene anche l’analisi del rischio compilata dall’erogatore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "PUBLISHED"
    When l'utente effettua una richiesta di export del descrittore
    Then si ottiene status code 200
    And il pacchetto risulta correttamente formattato
    And il documento di configurazione contiene anche l’analisi del rischio compilata dall’erogatore

  @descriptor_export5
  Scenario Outline: La richiesta di export di un descrittore di un e-service, con due documenti, va a buon fine e vengono esportati anche i documenti
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "PUBLISHED" e un documento già caricato
    Given l'utente ha già aggiunto un documento al descrittore
    When l'utente effettua una richiesta di export del descrittore
    Then si ottiene status code 200
    And il pacchetto risulta correttamente formattato
    And il pacchetto contiene anche i documenti che sono mappati nel documento di configurazione
