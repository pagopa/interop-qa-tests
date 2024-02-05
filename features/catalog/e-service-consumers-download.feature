@eservice_consumers
Feature: Download dei fruitori di un e-service
  Tutti gli utenti autenticati di enti erogatori possono scaricare l'elenco dei fruitori di un e-service

  @eservice_consumers1
  Scenario Outline: Per un e-service precedentemente creato e pubblicato, è possibile scaricare il file contenente l'elenco dei fruitori
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    Given "GSP" ha un agreement attivo con quell'e-service
    Given "PA2" ha un agreement attivo con quell'e-service
    When l'utente richiede una operazione di download dei fruitori di quell'e-service
    Then si ottiene status code 200

    Examples: 
      | ente | ruolo        |
      | PA1  | admin        |
      | PA1  | api          |
      | PA1  | security     |
      | PA1  | api,security |
      | PA1  | support      |
