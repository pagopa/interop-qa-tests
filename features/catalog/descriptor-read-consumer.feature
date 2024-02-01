@descriptor_read_consumer
Feature: Lettura di un descrittore lato fruitore
  Tutti gli utenti autenticati di enti fruitori possono leggere i descrittori degli e-service a catalogo

  @descriptor_read_consumer1
  Scenario Outline: Per un e-service precedentemente creato da qualsiasi ente, il quale ha un solo descrittore in stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la richiesta per ottenere i dettagli della versione di e-service va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente fruitore richiede la lettura di quel descrittore
    Then si ottiene status code 200

    Examples: 
      | ente | ruolo        | statoVersione |
      | GSP  | admin        | PUBLISHED     |
      | GSP  | admin        | SUSPENDED     |
      | GSP  | admin        | DEPRECATED    |
      | GSP  | admin        | ARCHIVED      |
      | GSP  | api          | PUBLISHED     |
      | GSP  | api          | SUSPENDED     |
      | GSP  | api          | DEPRECATED    |
      | GSP  | api          | ARCHIVED      |
      | GSP  | security     | PUBLISHED     |
      | GSP  | security     | SUSPENDED     |
      | GSP  | security     | DEPRECATED    |
      | GSP  | security     | ARCHIVED      |
      | GSP  | api,security | PUBLISHED     |
      | GSP  | api,security | SUSPENDED     |
      | GSP  | api,security | DEPRECATED    |
      | GSP  | api,security | ARCHIVED      |
      | GSP  | support      | PUBLISHED     |
      | GSP  | support      | SUSPENDED     |
      | GSP  | support      | DEPRECATED    |
      | GSP  | support      | ARCHIVED      |
      | PA1  | admin        | PUBLISHED     |
      | PA1  | admin        | SUSPENDED     |
      | PA1  | admin        | DEPRECATED    |
      | PA1  | admin        | ARCHIVED      |
      | PA1  | api          | PUBLISHED     |
      | PA1  | api          | SUSPENDED     |
      | PA1  | api          | DEPRECATED    |
      | PA1  | api          | ARCHIVED      |
      | PA1  | security     | PUBLISHED     |
      | PA1  | security     | SUSPENDED     |
      | PA1  | security     | DEPRECATED    |
      | PA1  | security     | ARCHIVED      |
      | PA1  | api,security | PUBLISHED     |
      | PA1  | api,security | SUSPENDED     |
      | PA1  | api,security | DEPRECATED    |
      | PA1  | api,security | ARCHIVED      |
      | PA1  | support      | PUBLISHED     |
      | PA1  | support      | SUSPENDED     |
      | PA1  | support      | DEPRECATED    |
      | PA1  | support      | ARCHIVED      |

  @descriptor_read_consumer2 @wait-for-fix #PIN-4479
  Scenario Outline: Per un e-service precedentemente creato da qualsiasi ente, il quale ha un solo descrittore in stato DRAFT, la richiesta per ottenere i dettagli della versione di e-service restituisce errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente fruitore richiede la lettura di quel descrittore
    Then si ottiene status code 403
