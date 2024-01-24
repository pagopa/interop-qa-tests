@eservice-read
Feature: Lettura di un e-service
  Tutti gli utenti autenticati di enti erogatori possono leggere un proprio e-service
 
  Scenario Outline: Per un e-service precedentemente creato dall’ente, il quale non ha descrittori, la richiesta per ottenere i dettagli dell'e-service va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given l'utente ha già creato un e-service senza descrittore
    When l'utente richiede la lettura di quell'e-service
    Then si ottiene status code 200

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |