@eservice_risk_analysis_addition

Feature: Aggiunta di un'analisi del rischio ad un eservice
  Tutti gli utenti autenticati di enti erogatori possono aggiungere un'analisi del rischio all'eservice se è in mode RECEIVE

  @eservice_risk_analysis_addition1
  Scenario Outline: Per un e-service creato con mode="RECEIVE", il quale non ha descrittori, è possibile inserire una nuova analisi del rischio. L'analisi del rischio deve essere ben formattata ma non necessariamente completamente compilata. La richiesta va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service in modalità "RECEIVE" senza descrittore
    When l'utente aggiunge un'analisi del rischio
    Then si ottiene status code 200

      Examples:
    | ente           | ruolo | 
    | GSP            | admin |
    | PA1            | admin |


  @eservice_risk_analysis_addition2
  Scenario Outline: Per un e-service creato con mode="RECEIVE", il quale ha un solo descrittore in stato DRAFT, è possibile inserire una nuova analisi del rischio. L'analisi del rischio deve essere ben formattata ma non necessariamente completamente compilata. La richiesta va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    When l'utente aggiunge un'analisi del rischio
    Then si ottiene status code 200

      Examples:
    | ente           | ruolo |      
    | GSP            | admin |
    | PA1            | admin |


  @eservice_risk_analysis_addition3
  Scenario Outline: Per un e-service creato con mode="DELIVER", il quale non ha descrittori, alla richiesta di inserimento di un analisi del rischio, ottiene un errore (NB: verificare lo status code dell’errore)
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service in modalità "DELIVER" senza descrittore
    When l'utente aggiunge un'analisi del rischio
    Then si ottiene status code 400

      Examples:
    | ente           | ruolo |      
    | GSP            | admin |
    | PA1            | admin |


  @eservice_risk_analysis_addition4
  Scenario Outline: Per un e-service creato con mode="DELIVER", il quale non Ha un solo descrittore in stato DRAFT, alla richiesta di inserimento di un analisi del rischio, ottiene un errore (NB: verificare lo status code dell’errore)
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service in modalità "DELIVER" con un descrittore in stato "DRAFT"
    When l'utente aggiunge un'analisi del rischio
    Then si ottiene status code 400

      Examples:
    | ente           | ruolo |      
    | GSP            | admin |
    | PA1            | admin |