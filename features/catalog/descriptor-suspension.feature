@descriptor_suspension
Feature: Sospensione di un descrittore
  Tutti gli utenti autenticati di enti erogatori possono sospendere i propri descrittori

  @descriptor_suspension1
  Scenario Outline: Per un e-service che ha un descrittore in stato PUBLISHED o DEPRECATED, alla richiesta di sospensione, la sospensione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente sospende quel descrittore
    Then si ottiene status code 204

    Examples: 
      | ente           | ruolo |      statoVersione |
      | GSP            | admin |      PUBLISHED     |
      | GSP            | admin |      DEPRECATED    |
      | PA1            | admin |      PUBLISHED     |
      | PA1            | admin |      DEPRECATED    |

 @descriptor_suspension2
  Scenario Outline: Per un e-service che ha un descrittore in stato ARCHIVED, DRAFT o SUSPENDED, alla richiesta di sospensione, ottiene un errore 
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente sospende quel descrittore
    Then si ottiene status code 400


    Examples: 
      | ente           | ruolo |      statoVersione |
      | GSP            | admin |      DRAFT         |
      | GSP            | admin |      SUSPENDED     |
      #| GSP            | admin |      ARCHIVED      |
      | PA1            | admin |      DRAFT         |
      | PA1            | admin |      SUSPENDED     |
      #| PA1            | admin |      ARCHIVED      |