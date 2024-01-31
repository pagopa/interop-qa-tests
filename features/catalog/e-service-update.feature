@eservice_updating
Feature: Aggiornamento di un e-service
  Tutti gli utenti autorizzati di enti erogatori possono aggiornare un proprio e-service
 
  @eservice_updating1
  Scenario Outline: Per un e-service precedentemente creato, il quale non ha descrittori, l'aggiornamento dei campi dell'e-service avviene correttamente
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service senza descrittore
    When l'utente aggiorna quell'e-service
    Then si ottiene status code <risultato>

    Examples: 
      | ente  | ruolo          | risultato |
      | GSP   | admin          | 200       |
      | GSP   | api            | 200       |
      | GSP   | security       | 403       |
      | GSP   | api,security   | 200       |
      | GSP   | support        | 403       |
      | PA1   | admin          | 200       |
      | PA1   | api            | 200       |
      | PA1   | security       | 403       |
      | PA1   | api,security   | 200       |
      | PA1   | support        | 403       |

  @eservice_updating2
  Scenario Outline: Per un e-service precedentemente creato, il quale ha un solo descrittore, il quale è in stato DRAFT, l’aggiornamento dei campi dell’e-service avviene correttamente
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente aggiorna quell'e-service
    Then si ottiene status code 200

  @eservice_updating3
  Scenario Outline: Per un e-service precedentemente creato, il quale ha un solo descrittore, il quale è in stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), l’aggiornamento dei campi dell’e-service restituisce errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
    When l'utente aggiorna quell'e-service
    Then si ottiene status code 400

    Examples: 
      | statoDescrittore |
      |    PUBLISHED     |
      |    SUSPENDED     |
      |    DEPRECATED    |
      |    ARCHIVED      |
