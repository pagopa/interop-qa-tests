@eservice_cloning
Feature: Clonazione di un e-service
  Tutti gli utenti autorizzati di enti erogatori possono clonare un proprio e-service e il relativo descrittore in stato PUBLISHED, SUSPENDED

  @eservice_cloning1
  Scenario Outline: Per un e-service che ha 2 descrittori, l’ultimo dei quali è in stato PUBLISHED/SUSPENDED, alla richiesta di clonazione, viene creato un nuovo e-service che ha un solo descrittore in stato DRAFT. Sia il nuovo e-service che il suo descrittore hanno esattamente le stesse caratteristiche dell’e-service e descrittore di partenza (ad eccezione del nome dell’e-service al quale viene aggiunto un “ - clone” alla fine;
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    Given un "admin" di "<ente>" ha già creato una versione in "<statoDescrittore>" per quell'e-service
    When l'utente clona quell'e-service
    Then si ottiene status code <risultato>

    Examples: # Test sui ruoli
      | ente | ruolo        | statoDescrittore | risultato |
      | GSP  | admin        | PUBLISHED        |       200 |
      | GSP  | api          | PUBLISHED        |       200 |
      | GSP  | security     | PUBLISHED        |       403 |
      | GSP  | api,security | PUBLISHED        |       200 |
      | GSP  | support      | PUBLISHED        |       403 |
      | PA1  | admin        | PUBLISHED        |       200 |
      | PA1  | api          | PUBLISHED        |       200 |
      | PA1  | security     | PUBLISHED        |       403 |
      | PA1  | api,security | PUBLISHED        |       200 |
      | PA1  | support      | PUBLISHED        |       403 |
    
    Examples: # Test sugli stati
      | ente | ruolo | statoDescrittore | risultato |
      | PA1  | admin | SUSPENDED       |       200 |
