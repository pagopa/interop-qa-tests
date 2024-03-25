@eservice_delete
Feature: Cancellazione di un e-service
  Tutti gli utenti autorizzati di enti erogatori possono cancellare un proprio e-service che non ha descrittori

  @eservice_delete1
  Scenario Outline: Per un e-service precedentemente creato, il quale non ha descrittori, la cancellazione dell'e-service avviene correttamente per i ruoli autorizzati
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service senza descrittore
    When l'utente cancella quell'e-service
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | risultato |
      | GSP  | admin        |       204 |
      | GSP  | api          |       204 |
      | GSP  | security     |       403 |
      | GSP  | api,security |       204 |
      | GSP  | support      |       403 |
      | PA1  | admin        |       204 |
      | PA1  | api          |       204 |
      | PA1  | security     |       403 |
      | PA1  | api,security |       204 |
      | PA1  | support      |       403 |

  @eservice_delete2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in qualsiasi stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), la cancellazione dell'e-service restituisce errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
    When l'utente cancella quell'e-service
    Then si ottiene status code 409

    Examples: 
      | statoDescrittore |
      | PUBLISHED        |
      | SUSPENDED        |
      | DEPRECATED       |
      | ARCHIVED         |


  @eservice_delete3
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, la cancellazione dell'e-service va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente cancella quell'e-service
    Then si ottiene status code 204

