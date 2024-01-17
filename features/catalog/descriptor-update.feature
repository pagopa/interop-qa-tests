@descriptor_update
Feature: Aggiornamento di un descrittore
  Tutti gli utenti autenticati di enti erogatori possono aggiornare i dati di un descrittore

  @descriptor_update1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, all’aggiornamento di alcuni parametri del descrittore, ben formattati, la bozza viene aggiornata correttamente
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente aggiorna alcuni parametri di quel descriptor
    Then si ottiene status code "200"

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |

  @descriptor_update2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), all’aggiornamento di alcuni parametri del descrittore, ben formattati, l’aggiornamento della bozza restituisce errore 
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente aggiorna alcuni parametri di quel descriptor
    Then si ottiene status code "400"

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

