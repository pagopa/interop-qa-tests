@descriptor_deletion
Feature: Cancellazione di un descrittore
  Tutti gli utenti autenticati di enti erogatori possono cancellare i propri descrittori e, potenzialmente, gli e-services

  @descriptor_deletion1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, la richiesta di cancellazione del descrittore cancella contestualmente anche l'e-service del quale fa parte
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente cancella il descriptor di quell'e-service
    Then si ottiene status code 204
    Then quell'eservice è stato cancellato

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |



 @descriptor_deletion2
  Scenario Outline: Per un e-service che ha più di un descrittore, l’ultimo dei quali è in stato DRAFT, la richiesta di cancellazione del descrittore cancella solo il descrittore stesso e non l’e-service del quale fa parte né nessuno degli altri descrittori dell’e-service
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    Given l'utente ha già creato una versione in bozza per quell'eservice
    When l'utente cancella il descriptor di quell'e-service
    Then si ottiene status code 204
    Then quell'eservice non è stato cancellato


    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |



  @descriptor_deletion3
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la richiesta di cancellazione del descrittore restituisce errore 
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente cancella il descriptor di quell'e-service
    Then si ottiene status code 500
    # // TO DO it should be 400 after the fix in backend

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

