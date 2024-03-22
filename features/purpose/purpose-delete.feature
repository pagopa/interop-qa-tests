@purpose-delete
Feature: Cancellazione finalità

  @purpose-delete1
  Scenario Outline: Per una finalità precedentemente creata dall’ente, la quale prima versione è in stato DRAFT, alla richiesta di cancellazione da parte di un utente con sufficienti permessi (admin), va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "<ruolo>" di "<ente>" ha già creato 1 finalità in stato "DRAFT" per quell'eservice
    When l'utente richiede la cancellazione della finalità
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | risultato |
      | PA1  | admin        |       200 |
      | PA1  | api          |       403 |
      | PA1  | security     |       403 |
      | PA1  | api,security |       403 |
      | PA1  | support      |       403 |
      | GSP  | admin        |       200 |
      | GSP  | api          |       403 |
      | GSP  | security     |       403 |
      | GSP  | api,security |       403 |
      | GSP  | support      |       403 |

  @purpose-delete2
  Scenario Outline: Per una finalità precedentemente creata dall’ente, la quale prima versione è in stato ACTIVE, SUSPENDED, WAITING_FOR_APPROVAL o ARCHIVED, alla richiesta di cancellazione da parte di un utente con sufficienti permessi (admin), ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente richiede la cancellazione della finalità
    Then si ottiene status code 200

    Examples: 
      | statoFinalita        |
      | ACTIVE               |
      | SUSPENDED            |
      | WAITING_FOR_APPROVAL |
      | ARCHIVED             |
