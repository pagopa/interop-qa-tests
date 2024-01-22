@deleting
Feature: Cancellazione di un e-service
  Tutti gli utenti autenticati di enti erogatori possono cancellare un proprio e-service che non ha descrittori
 
  @deleting1
  Scenario Outline: Per un e-service precedentemente creato, il quale non ha descrittori, la cancellazione dell'e-service avviene correttamente
    Given l'utente è un "<ruolo>" di "<ente>"
    Given l'utente ha già creato un e-service senza descrittore
    When l'utente cancella quell'e-service
    Then si ottiene status code 200

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |

  @deleting2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in qualsiasi stato (DRAFT, PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la cancellazione dell'e-service restituisce errore
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
    When l'utente cancella quell'e-service
    Then si ottiene status code 400

    Examples: 
      | ente           | ruolo | statoDescrittore |
      | GSP            | admin |    DRAFT     |
      | GSP            | admin |    PUBLISHED     |
      | GSP            | admin |    SUSPENDED     |
      | GSP            | admin |    DEPRECATED    |
      # | GSP            | admin |    ARCHIVED      |