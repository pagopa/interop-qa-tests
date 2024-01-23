@cloning
Feature: Clonazione di un e-service
  Tutti gli utenti autenticati di enti PA, GSP e privati possono clonare un proprio e-service e il relativo descrittore in stato PUBLISHED, SUSPENDED
 
  @cloning1
  Scenario Outline: Per un e-service che ha un solo descrittore in stato PUBLISHED, alla richiesta di clonazione, viene creato un nuovo e-service che ha un solo descrittore in stato DRAFT
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    When l'utente clona quell'e-service
    Then si ottiene status code 200

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |


  @cloning2
  Scenario Outline: Per un e-service che ha un solo descrittore in stato DRAFT, alla richiesta di clonazione, si ottiene un errore
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente clona quell'e-service
    Then si ottiene status code 400

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |
