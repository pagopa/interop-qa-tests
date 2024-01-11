@descriptor_deletion
Feature: Cancellazione di un descrittore
  Tutti gli utenti autenticati di enti erogatori possono cancellare i propri descrittori e, potenzialmente, gli e-services

  @descriptor_deletion1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, la richiesta di cancellazione del descrittore cancella contestualmente anche l'e-service del quale fa parte
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato Draft  # TODO
    When l'utente cancella il descriptor dell'e-service # TODO
    Then si ottiene status code 204 # TODO

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |


      