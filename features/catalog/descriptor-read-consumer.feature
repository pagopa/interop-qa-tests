@descriptor_read_consumer
Feature: Lettura di un descrittore lato fruitore
  Tutti gli utenti autenticati di enti fruitori possono leggere i descrittori degli e-service a catalogo

  @descriptor_read_consumer1
  Scenario Outline: Per un e-service precedentemente creato da qualsiasi ente, il quale ha un solo descrittore in stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la richiesta per ottenere i dettagli della versione di e-service va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente fruitore richiede la lettura di quel descrittore
    Then si ottiene status code 200

    Examples: 
      | ente    | ruolo        | statoVersione |
      | GSP     | admin        | PUBLISHED     |
      | GSP     | admin        | SUSPENDED     |
      | GSP     | admin        | DEPRECATED    |
      | GSP     | admin        | ARCHIVED      |
      | GSP     | api          | PUBLISHED     |
      | GSP     | api          | SUSPENDED     |
      | GSP     | api          | DEPRECATED    |
      | GSP     | api          | ARCHIVED      |
      | GSP     | security     | PUBLISHED     |
      | GSP     | security     | SUSPENDED     |
      | GSP     | security     | DEPRECATED    |
      | GSP     | security     | ARCHIVED      |
      | GSP     | api,security | PUBLISHED     |
      | GSP     | api,security | SUSPENDED     |
      | GSP     | api,security | DEPRECATED    |
      | GSP     | api,security | ARCHIVED      |
      | GSP     | support      | PUBLISHED     |
      | GSP     | support      | SUSPENDED     |
      | GSP     | support      | DEPRECATED    |
      | GSP     | support      | ARCHIVED      |
      | PA2     | admin        | PUBLISHED     |
      | PA2     | admin        | SUSPENDED     |
      | PA2     | admin        | DEPRECATED    |
      | PA2     | admin        | ARCHIVED      |
      | PA2     | api          | PUBLISHED     |
      | PA2     | api          | SUSPENDED     |
      | PA2     | api          | DEPRECATED    |
      | PA2     | api          | ARCHIVED      |
      | PA2     | security     | PUBLISHED     |
      | PA2     | security     | SUSPENDED     |
      | PA2     | security     | DEPRECATED    |
      | PA2     | security     | ARCHIVED      |
      | PA2     | api,security | PUBLISHED     |
      | PA2     | api,security | SUSPENDED     |
      | PA2     | api,security | DEPRECATED    |
      | PA2     | api,security | ARCHIVED      |
      | PA2     | support      | PUBLISHED     |
      | PA2     | support      | SUSPENDED     |
      | PA2     | support      | DEPRECATED    |
      | PA2     | support      | ARCHIVED      |
      | Privato | admin        | PUBLISHED     |
      | Privato | admin        | SUSPENDED     |
      | Privato | admin        | DEPRECATED    |
      | Privato | admin        | ARCHIVED      |
      | Privato | api          | PUBLISHED     |
      | Privato | api          | SUSPENDED     |
      | Privato | api          | DEPRECATED    |
      | Privato | api          | ARCHIVED      |
      | Privato | security     | PUBLISHED     |
      | Privato | security     | SUSPENDED     |
      | Privato | security     | DEPRECATED    |
      | Privato | security     | ARCHIVED      |
      | Privato | api,security | PUBLISHED     |
      | Privato | api,security | SUSPENDED     |
      | Privato | api,security | DEPRECATED    |
      | Privato | api,security | ARCHIVED      |
      | Privato | support      | PUBLISHED     |
      | Privato | support      | SUSPENDED     |
      | Privato | support      | DEPRECATED    |
      | Privato | support      | ARCHIVED      |

  @descriptor_read_consumer2
  Scenario Outline: Per un e-service precedentemente creato da qualsiasi ente, il quale ha un solo descrittore in stato DRAFT, la richiesta per ottenere i dettagli della versione di e-service restituisce errore
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente fruitore richiede la lettura di quel descrittore
    Then si ottiene status code 404
