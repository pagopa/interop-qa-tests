@eservice_risk_analysis_delete

Feature: Cancellazione di un'analisi del rischio ad un e-service
  Tutti gli utenti autenticati di enti erogatori possono cancellare un'analisi del rischio di un e-service se è in mode RECEIVE

  @eservice_risk_analysis_delete1
  Scenario Outline: Per un e-service creato con mode="RECEIVE", il quale non ha descrittori, è possibile cancellare un'analisi del rischio precedentemente creata. L'analisi del rischio deve essere ben formattata ma non necessariamente completamente compilata. La richiesta va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service in modalità "RECEIVE" senza descrittore
    Given l'utente ha già aggiunto un'analisi del rischio a quell'e-service
    When l'utente cancella quell'analisi del rischio
    Then si ottiene status code 200

      Examples:
    | ente           | ruolo | 
    | GSP            | admin |
    | PA1            | admin |


  @eservice_risk_analysis_delete2
  Scenario Outline: Per un e-service creato con mode="RECEIVE", il quale ha un solo descrittore in stato DRAFT, è possibile cancellare un'analisi del rischio precedentemente creata. L'analisi del rischio deve essere ben formattata ma non necessariamente completamente compilata. La richiesta va a buon fine
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "GSP" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given l'utente ha già aggiunto un'analisi del rischio a quell'e-service
    When l'utente cancella quell'analisi del rischio
    Then si ottiene status code 200
