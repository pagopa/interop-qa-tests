@cloning
Feature: Clonazione di un e-service
  Tutti gli utenti autenticati di enti erogatori possono clonare un proprio e-service e il relativo descrittore in stato PUBLISHED, SUSPENDED
 
  @cloning1
  Scenario Outline: Per un e-service che ha 2 descrittori, l’ultimo dei quali è in stato PUBLISHED/SUSPENDED, alla richiesta di clonazione, viene creato un nuovo e-service che ha un solo descrittore in stato DRAFT. Sia il nuovo e-service che il suo descrittore hanno esattamente le stesse caratteristiche dell’e-service e descrittore di partenza (ad eccezione del nome dell’e-service al quale viene aggiunto un “ - clone” alla fine;
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    Given l'utente ha già creato una versione in "<statoDescrittore>" per quell'eservice
    When l'utente clona quell'e-service
    Then si ottiene status code 200

    Examples: 
      | ente           | ruolo |  statoDescrittore |
      | PA1            | admin |    PUBLISHED      |
      | PA1            | admin |    SUSPENDED      |
