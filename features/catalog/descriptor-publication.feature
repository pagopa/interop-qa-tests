@descriptor_publication
Feature: Pubblicazione di un descrittore
  Tutti gli utenti autenticati di enti erogatori possono pubblicare i propri descrittori

  @descriptor_publication1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, con tutti i parametri richiesti inseriti e formattati correttamente, alla richiesta di pubblicazione, la bozza viene pubblicata correttamente
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "DRAFT"
    Given l'utente ha già caricato un'interfaccia per quel descrittore
    When l'utente pubblica quel descrittore
    Then si ottiene status code 204

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |

 @descriptor_publication2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale non è in stato DRAFT, alla richiesta di pubblicazione, si ottiene un errore
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente pubblica quel descrittore
    Then si ottiene status code 400


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

  @descriptor_publication3
  Scenario Outline: Per un e-service creato in modalità "RECEIVE" che ha un solo descrittore, il quale è in stato DRAFT, con tutti i parametri richiesti inseriti e formattati correttamente, senza nessuna analisi del rischio inserita, alla richiesta di pubblicazione, ottiene un errore
    Given l'utente è un "admin" di "GSP"
    Given l'utente ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given l'utente ha già caricato un'interfaccia per quel descrittore
    When l'utente pubblica quel descrittore
    Then si ottiene status code 400

  @descriptor_publication4
  Scenario Outline: Per un e-service creato in modalità "RECEIVE" che ha un solo descrittore, il quale è in stato DRAFT, con tutti i parametri richiesti inseriti e formattati correttamente, e con un’analisi del rischio compilata solo parzialmente, alla richiesta di pubblicazione, ottiene un errore
    Given l'utente è un "admin" di "GSP"
    Given l'utente ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given l'utente ha già caricato un'interfaccia per quel descrittore
    Given l'utente ha compilato parzialmente l'analisi del rischio
    When l'utente pubblica quel descrittore
    Then si ottiene status code 400
