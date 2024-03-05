@agreement_submit
Feature: Inoltro della richiesta di fruizione
Tutti gli utenti autorizzati possono inoltrare una richiesta di fruizione

  @agreement_submit1
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato DRAFT, associata ad un e-service nella sua ultima versione pubblicata, la quale è in stato PUBLISHED, all'inoltro della richiesta di fruizione da parte di un utente con sufficienti permessi dell’ente fruitore, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "<ente>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    When l'utente inoltra quella richiesta di fruizione
    Then si ottiene status code 200

    Examples: 
      | enteErogatore | ruolo        | risultato |
      | GSP           | admin        |       200 |
      | GSP           | api          |       403 |
      | GSP           | security     |       403 |
      | GSP           | support      |       403 |
      | GSP           | api,security |       403 |
      | PA1           | admin        |       200 |
      | PA1           | api          |       403 |
      | PA1           | security     |       403 |
      | PA1           | support      |       403 |
      | PA1           | api,security |       403 |
      | Privato       | admin        |       200 |
      | Privato       | api          |       403 |
      | Privato       | security     |       403 |
      | Privato       | support      |       403 |
      | Privato       | api,security |       403 |

  @agreement_submit2
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato DRAFT, associata ad un e-service nella sua ultima versione pubblicata, la quale è in stato SUSPENDED, all'inoltro della richiesta di fruizione da parte di un utente con sufficienti permessi dell’ente fruitore, dà errore
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato un e-service in stato "SUSPENDED" con approvazione "AUTOMATIC"
    Given "<ente>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    When l'utente inoltra la richiesta di fruizione
    Then si ottiene status code 400

  @agreement_submit3
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato DRAFT, associata ad un e-service nella sua ultima versione pubblicata, con NON tutti gli attributi richiesti certificati, all’inoltro della richiesta di fruizione da parte di un utente con sufficienti permessi dell’ente fruitore, che è anche l’erogatore dell’e-service, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato un e-service in stato "SUSPENDED" con approvazione "AUTOMATIC"
    Given "<ente>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    When l'utente inoltra la richiesta di fruizione
    Then si ottiene status code 400
