@descriptor_export
Feature: Export di un descrittore
  Tutti gli utenti autorizzatipossono effettuare una richiesta di export di un descrittore di un e-service che il proprio ente eroga.

  @descriptor_export1
  Scenario Outline: La richiesta di export di un descrittore di un e-service, senza documenti, in stato NON DRAFT, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
    When l'utente effettua una richiesta di export del descrittore
    Then si ottiene status code <risultato>
    And il pacchetto risulta correttamente formattato

    Examples:
      | ente | ruolo        | statoDescrittore | risultato |
      | GSP  | admin        | PUBLISHED        |       200 |
      | GSP  | api          | PUBLISHED        |       200 |
      | GSP  | security     | PUBLISHED        |       200 |
      | GSP  | api,security | PUBLISHED        |       200 |
      | GSP  | support      | PUBLISHED        |       200 |
      | PA1  | admin        | PUBLISHED        |       200 |
      | PA1  | api          | PUBLISHED        |       200 |
      | PA1  | security     | PUBLISHED        |       200 |
      | PA1  | api,security | PUBLISHED        |       200 |
      | PA1  | support      | PUBLISHED        |       200 |

    Examples:
      | ente | ruolo | statoDescrittore | risultato |
      | PA1  | admin | DRAFT            |       400 |
      | PA1  | admin | ARCHIVED         |       200 |
      | PA1  | admin | DEPRECATED       |       200 |
      | PA1  | admin | ARCHIVED         |       200 |

  @descriptor_export2
  Scenario Outline: La richiesta di export di un descrittore di un e-service, senza documenti, da parte di un ente che non è l’erogatore, ritorna un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    When l'utente effettua una richiesta di export del descrittore
    Then si ottiene status code 400

  @descriptor_export3
  Scenario Outline: La richiesta di export di un descrittore di un e-service, senza documenti, in erogazione inversa, con un’analisi del rischio compilata, va a buon fine. Il documento di configurazione che è parte del pacchetto esportato contiene anche l’analisi del rischio compilata dall’erogatore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    When l'utente effettua una richiesta di export del descrittore
    Then si ottiene status code 200
    And il pacchetto risulta correttamente formattato
    And il documento di configurazione contiene anche l’analisi del rischio compilata dall’erogatore

  @descriptor_export4
  Scenario Outline: La richiesta di export di un descrittore di un e-service, con documenti, va a buon fine e vengono esportati anche i documenti
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    When l'utente effettua una richiesta di export del descrittore
    Then si ottiene status code 200
    And il pacchetto risulta correttamente formattato
    And il pacchetto contiene anche i documenti che sono mappati nel documento di configurazione
