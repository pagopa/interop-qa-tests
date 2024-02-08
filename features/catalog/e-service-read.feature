@eservice_read
Feature: Lettura di un e-service
  Tutti gli utenti autorizzati di enti erogatori possono leggere un proprio e-service

  @eservice_read1
  Scenario Outline: Per un e-service precedentemente creato dall’ente, il quale non ha descrittori, la richiesta per ottenere i dettagli dell'e-service va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service senza descrittore
    When l'utente richiede la lettura di quell'e-service
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | risultato |
      | GSP  | admin        |       200 |
      | GSP  | api          |       200 |
      | GSP  | security     |       404 |
      | GSP  | api,security |       200 |
      | GSP  | support      |       404 |
      | PA1  | admin        |       200 |
      | PA1  | api          |       200 |
      | PA1  | security     |       404 |
      | PA1  | api,security |       200 |
      | PA1  | support      |       404 |
