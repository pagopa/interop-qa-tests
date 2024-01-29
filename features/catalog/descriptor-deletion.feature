@descriptor_deletion
Feature: Cancellazione di un descrittore
  Tutti gli utenti autenticati di enti erogatori possono cancellare i propri descrittori e, potenzialmente, gli e-services

  @descriptor_deletion1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, la richiesta di cancellazione del descrittore cancella contestualmente anche l'e-service del quale fa parte
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "GSP" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente cancella il descriptor di quell'e-service
    Then si ottiene status code 204
    Then quell'eservice è stato cancellato

 @descriptor_deletion2
  Scenario Outline: Per un e-service che ha più di un descrittore, l’ultimo dei quali è in stato DRAFT, la richiesta di cancellazione del descrittore cancella solo il descrittore stesso e non l’e-service del quale fa parte né nessuno degli altri descrittori dell’e-service
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "GSP" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    Given l'utente ha già creato una versione in bozza per quell'eservice
    When l'utente cancella il descriptor di quell'e-service
    Then si ottiene status code 204
    Then quell'eservice non è stato cancellato

  @descriptor_deletion3
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la richiesta di cancellazione del descrittore restituisce errore 
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "GSP" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente cancella il descriptor di quell'e-service
    Then si ottiene status code 400

    Examples: 
      |      statoVersione |
      |      PUBLISHED     |
      |      SUSPENDED     |
      |      DEPRECATED    |
      |      ARCHIVED      |
