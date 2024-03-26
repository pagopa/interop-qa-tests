@descriptor_read_producer
Feature: Lettura di un descrittore lato erogatore
  Tutti gli utenti autorizzati di enti erogatori possono leggere i propri descrittori

  @descriptor_read_producer1
  Scenario Outline: Per un e-service precedentemente creato dall’ente, il quale ha un solo descrittore in qualsiasi stato (DRAFT, PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la richiesta per ottenere i dettagli della versione di e-service, da parte di un utente autorizzato, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente richiede la lettura di quel descrittore
    Then si ottiene status code <risultato>

    Examples: # Test sui ruoli
      | ente | ruolo        | statoVersione | risultato |
      | PA1  | admin        | DRAFT         |       200 |
      | PA1  | api          | DRAFT         |       200 |
      | PA1  | security     | DRAFT         |       404 |
      | PA1  | api,security | DRAFT         |       200 |
      | PA1  | support      | DRAFT         |       404 |
      | GSP  | admin        | DRAFT         |       200 |
      | GSP  | api          | DRAFT         |       200 |
      | GSP  | security     | DRAFT         |       404 |
      | GSP  | api,security | DRAFT         |       200 |
      | GSP  | support      | DRAFT         |       404 |

    Examples: # Test sugli stati
      | ente | ruolo | statoVersione | risultato |
      | PA1  | admin | PUBLISHED     |       200 |
      | PA1  | admin | SUSPENDED     |       200 |
      | PA1  | admin | DEPRECATED    |       200 |
      | PA1  | admin | ARCHIVED      |       200 |

  @descriptor_read_producer2
  Scenario Outline: Per un e-service precedentemente creato da un altro ente, il quale ha un solo descrittore in qualsiasi stato (DRAFT, PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la richiesta per ottenere i dettagli della versione di e-service restituisce errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente richiede la lettura di quel descrittore
    Then si ottiene status code <risultato>

    Examples: 
      | statoVersione | risultato |
      | PUBLISHED     |       403 |
      | SUSPENDED     |       403 |
      | DEPRECATED    |       403 |
      | DRAFT         |       404 |
      | ARCHIVED      |       403 |
