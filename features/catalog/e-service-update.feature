@eservice_updating
Feature: Aggiornamento di un e-service
  Tutti gli utenti autenticati di enti erogatori possono aggiornare un proprio e-service
 
  @eservice_updating1
  Scenario Outline: Per un e-service precedentemente creato, il quale non ha descrittori, l'aggiornamento dei campi dell'e-service avviene correttamente
    Given l'utente è un "<ruolo>" di "<ente>"
    Given l'utente ha già creato un e-service senza descrittore
    When l'utente aggiorna quell'e-service
    Then si ottiene status code 200

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |

  @eservice_updating2
  Scenario Outline: Per un e-service precedentemente creato, il quale ha un solo descrittore, il quale è in stato DRAFT, l’aggiornamento dei campi dell’e-service avviene correttamente
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente aggiorna quell'e-service
    Then si ottiene status code 200

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |

  @eservice_updating3
  Scenario Outline: Per un e-service precedentemente creato, il quale ha un solo descrittore, il quale è in stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), l’aggiornamento dei campi dell’e-service restituisce errore
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
    When l'utente aggiorna quell'e-service
    Then si ottiene status code 400

    Examples: 
      | ente           | ruolo | statoDescrittore |
      | GSP            | admin |    PUBLISHED     |
      | GSP            | admin |    SUSPENDED     |
      | GSP            | admin |    DEPRECATED    |
      # | GSP            | admin |    ARCHIVED      |