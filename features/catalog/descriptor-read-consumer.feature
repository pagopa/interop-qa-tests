@descriptor_read_consumer
Feature: Lettura di un descrittore lato fruitore
  Tutti gli utenti autenticati di enti fruitori possono leggere i descrittori degli eservice a catalogo

  @descriptor_read_consumer1
  Scenario Outline: Per un e-service precedentemente creato da qualsiasi ente, il quale ha un solo descrittore in stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la richiesta per ottenere i dettagli della versione di e-service va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "GSP" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente fruitore richiede la lettura di quel descrittore
    Then si ottiene status code 200
    
    Examples: 
      | ente           | ruolo |      statoVersione |
      | GSP            | admin |      PUBLISHED     |
      | GSP            | admin |      SUSPENDED     |
      | GSP            | admin |      DEPRECATED    |
      #| GSP            | admin |      ARCHIVED      |
      | PA1            | admin |      PUBLISHED     |
      | PA1            | admin |      SUSPENDED     |
      | PA1            | admin |      DEPRECATED    |
      #| PA1            | admin |      ARCHIVED      |
      | Privato        | admin |      PUBLISHED     |
      | Privato        | admin |      SUSPENDED     |
      | Privato        | admin |      DEPRECATED    |
      #| Privato        | admin |      ARCHIVED      |

 @descriptor_read_consumer2 @wait-for-fix
  Scenario Outline: Per un e-service precedentemente creato da qualsiasi ente, il quale ha un solo descrittore in stato DRAFT, la richiesta per ottenere i dettagli della versione di e-service restituisce errore
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente fruitore richiede la lettura di quel descrittore
    Then si ottiene status code 403
