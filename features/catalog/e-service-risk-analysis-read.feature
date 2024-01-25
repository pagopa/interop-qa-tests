@eservice_risk_analysis_read

Feature: Lettura di un'analisi del rischio di un eservice
  Tutti gli utenti autenticati possono leggere l'analisi del rischio di un eservice

  @eservice_risk_analysis_read1
  Scenario Outline: Per un e-service precedentemente creato e pubblicato con mode="RECEIVE", alla richiesta di lettura di una sua analisi del rischio, l'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "PUBLISHED"
    When l'utente legge l'analisi del rischio di quell'eservice
    Then si ottiene status code 200

      Examples:
    | ente           | ruolo | 
    | GSP            | admin |
    | PA1            | admin |
