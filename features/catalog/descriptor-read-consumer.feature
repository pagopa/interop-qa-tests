@descriptor_read_consumer
Feature: Lettura di un descrittore lato fruitore
  Tutti gli utenti autenticati di enti fruitori possono leggere i descrittori degli e-service a catalogo

  @descriptor_read_consumer1
  Scenario Outline: Per un e-service precedentemente creato da qualsiasi ente, il quale ha un solo descrittore in stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la richiesta per ottenere i dettagli della versione di e-service va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente fruitore richiede la lettura di quel descrittore
    Then si ottiene status code 200

    Examples: 
      | ente    | ruolo        | statoVersione |
      | GSP     | admin        | PUBLISHED     |
      | GSP     | api          | PUBLISHED     |
      | GSP     | security     | PUBLISHED     |
      | GSP     | api,security | PUBLISHED     |
      | GSP     | support      | PUBLISHED     |
      | PA1     | admin        | PUBLISHED     |
      | PA1     | api          | PUBLISHED     |
      | PA1     | security     | PUBLISHED     |
      | PA1     | api,security | PUBLISHED     |
      | PA1     | support      | PUBLISHED     |
      | Privato | admin        | PUBLISHED     |
      | Privato | api          | PUBLISHED     |
      | Privato | security     | PUBLISHED     |
      | Privato | api,security | PUBLISHED     |
      | Privato | support      | PUBLISHED     |

    Examples: 
      | ente | ruolo | statoVersione |
      | PA1  | admin | SUSPENDED     |
      | PA1  | admin | DEPRECATED    |
      | PA1  | admin | ARCHIVED      |

  @descriptor_read_consumer2
  Scenario Outline: Per un e-service precedentemente creato da qualsiasi ente, il quale ha un solo descrittore in stato DRAFT, la richiesta per ottenere i dettagli della versione di e-service restituisce errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente fruitore richiede la lettura di quel descrittore
    Then si ottiene status code 404
