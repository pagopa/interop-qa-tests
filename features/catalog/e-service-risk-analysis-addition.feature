@eservice_risk_analysis_addition
Feature: Aggiunta di un'analisi del rischio ad un e-service
  Tutti gli utenti autorizzati di enti erogatori possono aggiungere un'analisi del rischio all'e-service se è in mode RECEIVE

  @eservice_risk_analysis_addition1
  Scenario Outline: Per un e-service creato in modalità "RECEIVE", il quale non ha descrittori, è possibile inserire una nuova analisi del rischio. L'analisi del rischio deve essere ben formattata ma non necessariamente completamente compilata. La richiesta va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato un e-service in modalità "RECEIVE" senza descrittore
    When l'utente aggiunge un'analisi del rischio
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

  @eservice_risk_analysis_addition2
  Scenario Outline: Per un e-service creato in modalità "RECEIVE", il quale ha un solo descrittore in stato DRAFT, è possibile inserire una nuova analisi del rischio. L'analisi del rischio deve essere ben formattata ma non necessariamente completamente compilata. La richiesta va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    When l'utente aggiunge un'analisi del rischio
    Then si ottiene status code 204

  @eservice_risk_analysis_addition3
  Scenario Outline: Per un e-service creato in modalità "DELIVER", il quale non ha descrittori, alla richiesta di inserimento di un'analisi del rischio, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in modalità "DELIVER" senza descrittore
    When l'utente aggiunge un'analisi del rischio
    Then si ottiene status code 400

  @eservice_risk_analysis_addition4
  Scenario Outline: Per un e-service creato in modalità "DELIVER", il quale ha un solo descrittore in stato DRAFT, alla richiesta di inserimento di un'analisi del rischio, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in modalità "DELIVER" con un descrittore in stato "DRAFT"
    When l'utente aggiunge un'analisi del rischio
    Then si ottiene status code 400

  @eservice_risk_analysis_addition5
  Scenario Outline: Per un e-service creato in modalità "RECEIVE", il quale non ha descrittori, alla richiesta di inserimento di un'analisi del rischio ben formattata e dell'ultima versione per quella tipologia di ente ma della tipologia errata, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in modalità "RECEIVE" senza descrittore
    When l'utente aggiunge un'analisi del rischio non corretta per la tipologia di ente
    Then si ottiene status code 400

  @eservice_risk_analysis_addition6
  Scenario Outline: Per un e-service creato in modalità "RECEIVE", il quale ha un solo descrittore in stato DRAFT, alla richiesta di inserimento di un'analisi del rischio ben formattata e della versione corretta per quella tipologia di ente ma della tipologia errata, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    When l'utente aggiunge un'analisi del rischio non corretta per la tipologia di ente
    Then si ottiene status code 400

  @eservice_risk_analysis_addition7
  Scenario Outline: Per un e-service creato in modalità "RECEIVE", il quale non ha descrittori, alla richiesta di inserimento di un'analisi del rischio ben formattata e della tipologia corretta per quella tipologia di ente ma in una versione che non è la “latest”, l’ultima disponibile, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in modalità "RECEIVE" senza descrittore
    When l'utente aggiunge un'analisi del rischio con versione template non aggiornata
    Then si ottiene status code 400

  @eservice_risk_analysis_addition8
  Scenario Outline: Per un e-service creato in modalità "RECEIVE", il quale ha un solo descrittore in stato DRAFT, alla richiesta di inserimento di un'analisi del rischio ben formattata e della tipologia corretta per quella tipologia di ente ma in una versione che non è la “latest”, l’ultima disponibile, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    When l'utente aggiunge un'analisi del rischio con versione template non aggiornata
    Then si ottiene status code 400
