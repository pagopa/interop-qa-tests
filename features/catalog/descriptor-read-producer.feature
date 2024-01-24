@descriptor_read_producer
Feature: Lettura di un descrittore lato erogatore
  Tutti gli utenti autenticati di enti erogatori possono leggere i propri descrittori

  @descriptor_read_producer1
  Scenario Outline: Per un e-service precedentemente creato dall’ente, il quale ha un solo descrittore in qualsiasi stato (DRAFT, PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la richiesta per ottenere i dettagli della versione di e-service va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente richiede la lettura di quel descrittore
    Then si ottiene status code 200

    Examples: 
      | ente           | ruolo |      statoVersione |
      | GSP            | admin |      PUBLISHED     |
      | GSP            | admin |      SUSPENDED     |
      | GSP            | admin |      DEPRECATED    |
      | GSP            | admin |      DRAFT         |
      #| GSP            | admin |      ARCHIVED      |
      | PA1            | admin |      PUBLISHED     |
      | PA1            | admin |      SUSPENDED     |
      | PA1            | admin |      DEPRECATED    |
      | PA1            | admin |      DRAFT         |
      #| PA1            | admin |      ARCHIVED      |

 @descriptor_read_producer2
  Scenario Outline: Per un e-service precedentemente creato da un altro ente, il quale ha un solo descrittore in qualsiasi stato (DRAFT, PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la richiesta per ottenere i dettagli della versione di e-service restituisce errore
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente richiede la lettura di quel descrittore
    Then si ottiene status code 403

    Examples: 
      |      statoVersione |
      |      PUBLISHED     |
      |      SUSPENDED     |
      |      DEPRECATED    |
      |      DRAFT         |
      #|      ARCHIVED      |
      |      PUBLISHED     |
      |      SUSPENDED     |
      |      DEPRECATED    |
      |      DRAFT         |
      #|      ARCHIVED      |