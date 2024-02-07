@eservice_risk_analysis_update
Feature: Aggiornamento di un'analisi del rischio ad un e-service
  Tutti gli utenti autenticati di enti erogatori possono aggiornare un'analisi del rischio ad un e-service se è in mode RECEIVE

  @eservice_risk_analysis_update1
  Scenario Outline: Per un e-service creato in modalità "RECEIVE", il quale non ha descrittori, è possibile aggiornare un'analisi del rischio precedentemente creata. L'analisi del rischio deve essere ben formattata ma non necessariamente completamente compilata. La richiesta va a buon fine se è un utente autorizzato
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service in modalità "RECEIVE" senza descrittore
    Given un "admin" di "<ente>" ha già aggiunto un'analisi del rischio a quell'e-service
    When l'utente aggiorna l'analisi del rischio di quell'e-service
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

  @eservice_risk_analysis_update2
  Scenario Outline: Per un e-service creato in modalità "RECEIVE", il quale ha un solo descrittore in stato DRAFT, è possibile aggiornare un'analisi del rischio precedentemente creata. L'analisi del rischio deve essere ben formattata ma non necessariamente completamente compilata. La richiesta va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given un "admin" di "PA1" ha già aggiunto un'analisi del rischio a quell'e-service
    When l'utente aggiorna l'analisi del rischio di quell'e-service
    Then si ottiene status code 204
