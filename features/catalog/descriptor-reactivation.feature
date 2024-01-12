@descriptor_activation
Feature: Aggiornamento di un descrittore
  Tutti gli utenti autenticati di enti erogatori possono attivare (ripubblicare) un descrittore in stato SUSPENDED

  @descriptor_activation1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato SUSPENDED, alla attivazione del descrittore, si ripubblica correttamente
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "SUSPENDED"
    When l'utente attiva il descriptor dell'e-service # TODO
    Then si ottiene status code 204 # TODO

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |
  
  @descriptor_activation3
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato ARCHIVED oppure DRAFT, alla riattivazione del descrittore, ottiene un errore
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
    When l'utente attiva il descriptor dell'e-service # TODO
    Then si ottiene status code 400 # TODO

    Examples: 
      | ente           | ruolo | statoDescrittore |
      | GSP            | admin | ARCHIVED         |
      | PA1            | admin | DRAFT            |