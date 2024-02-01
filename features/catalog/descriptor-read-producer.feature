@descriptor_read_producer
Feature: Lettura di un descrittore lato erogatore
  Tutti gli utenti autorizzati di enti erogatori possono leggere i propri descrittori

  @descriptor_read_producer1 @wait-for-fix
  Scenario Outline: Per un e-service precedentemente creato dall’ente, il quale ha un solo descrittore in qualsiasi stato (DRAFT, PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la richiesta per ottenere i dettagli della versione di e-service, da parte di un utente autorizzato, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente richiede la lettura di quel descrittore
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | statoVersione | risultato |
      | GSP  | admin        | DRAFT         |       200 |
      | GSP  | admin        | PUBLISHED     |       200 |
      | GSP  | admin        | SUSPENDED     |       200 |
      | GSP  | admin        | DEPRECATED    |       200 |
      | GSP  | admin        | ARCHIVED      |       200 |
      | GSP  | api          | DRAFT         |       403 |
      | GSP  | api          | PUBLISHED     |       200 |
      | GSP  | api          | SUSPENDED     |       200 |
      | GSP  | api          | DEPRECATED    |       200 |
      | GSP  | api          | ARCHIVED      |       200 |
      | GSP  | security     | DRAFT         |       403 |
      | GSP  | security     | PUBLISHED     |       200 |
      | GSP  | security     | SUSPENDED     |       200 |
      | GSP  | security     | DEPRECATED    |       200 |
      | GSP  | security     | ARCHIVED      |       200 |
      | GSP  | api,security | DRAFT         |       200 |
      | GSP  | api,security | PUBLISHED     |       200 |
      | GSP  | api,security | SUSPENDED     |       200 |
      | GSP  | api,security | DEPRECATED    |       200 |
      | GSP  | api,security | ARCHIVED      |       200 |
      | GSP  | support      | DRAFT         |       403 |
      | GSP  | support      | PUBLISHED     |       200 |
      | GSP  | support      | SUSPENDED     |       200 |
      | GSP  | support      | DEPRECATED    |       200 |
      | GSP  | support      | ARCHIVED      |       200 |
      | PA1  | admin        | DRAFT         |       200 |
      | PA1  | admin        | PUBLISHED     |       200 |
      | PA1  | admin        | SUSPENDED     |       200 |
      | PA1  | admin        | DEPRECATED    |       200 |
      | PA1  | admin        | ARCHIVED      |       200 |
      | PA1  | api          | DRAFT         |       403 |
      | PA1  | api          | PUBLISHED     |       200 |
      | PA1  | api          | SUSPENDED     |       200 |
      | PA1  | api          | DEPRECATED    |       200 |
      | PA1  | api          | ARCHIVED      |       200 |
      | PA1  | security     | DRAFT         |       403 |
      | PA1  | security     | PUBLISHED     |       200 |
      | PA1  | security     | SUSPENDED     |       200 |
      | PA1  | security     | DEPRECATED    |       200 |
      | PA1  | security     | ARCHIVED      |       200 |
      | PA1  | api,security | DRAFT         |       200 |
      | PA1  | api,security | PUBLISHED     |       200 |
      | PA1  | api,security | SUSPENDED     |       200 |
      | PA1  | api,security | DEPRECATED    |       200 |
      | PA1  | api,security | ARCHIVED      |       200 |
      | PA1  | support      | DRAFT         |       403 |
      | PA1  | support      | PUBLISHED     |       200 |
      | PA1  | support      | SUSPENDED     |       200 |
      | PA1  | support      | DEPRECATED    |       200 |
      | PA1  | support      | ARCHIVED      |       200 |

  @descriptor_read_producer2
  Scenario Outline: Per un e-service precedentemente creato da un altro ente, il quale ha un solo descrittore in qualsiasi stato (DRAFT, PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la richiesta per ottenere i dettagli della versione di e-service restituisce errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente richiede la lettura di quel descrittore
    Then si ottiene status code 403

    Examples: 
      | statoVersione |
      | PUBLISHED     |
      | SUSPENDED     |
      | DEPRECATED    |
      | DRAFT         |
      | ARCHIVED      |
