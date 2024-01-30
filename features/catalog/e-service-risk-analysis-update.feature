@eservice_risk_analysis_update

Feature: Aggiornamento di un'analisi del rischio ad un e-service
  Tutti gli utenti autenticati di enti erogatori possono aggiornare un'analisi del rischio ad un e-service se è in mode RECEIVE

  @eservice_risk_analysis_update1
  Scenario Outline: Per un e-service creato con mode="RECEIVE", il quale non ha descrittori, è possibile aggiornare un'analisi del rischio precedentemente creata. L'analisi del rischio deve essere ben formattata ma non necessariamente completamente compilata. La richiesta va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given l'utente ha già creato un e-service in modalità "RECEIVE" senza descrittore
    Given l'utente ha già aggiunto un'analisi del rischio a quell'e-service
    When l'utente aggiorna l'analisi del rischio di quell'e-service
    Then si ottiene status code 204

      Examples:
    | ente           | ruolo | 
    | GSP            | admin |
    | PA1            | admin |


  @eservice_risk_analysis_update2
  Scenario Outline: Per un e-service creato con mode="RECEIVE", il quale ha un solo descrittore in stato DRAFT, è possibile aggiornare un'analisi del rischio precedentemente creata. L'analisi del rischio deve essere ben formattata ma non necessariamente completamente compilata. La richiesta va a buon fine
    Given l'utente è un "admin" di "GSP"
    Given l'utente ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given l'utente ha già aggiunto un'analisi del rischio a quell'e-service
    When l'utente aggiorna l'analisi del rischio di quell'e-service
    Then si ottiene status code 204
