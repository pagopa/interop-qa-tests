@client_delete
Feature: Cancellazione client
  Tutti gli utenti admin possono cancellare il proprio client

  @client_delete1
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client, richiede la cancellazione del client. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 client "e-service"
    When l'utente richiede una operazione di cancellazione di quel client
    Then si ottiene status code <statusCode>

    Examples:
      | ente    | ruolo        | statusCode |
      | GSP     | admin        |        200 |
      | GSP     | api          |        400 |
      | GSP     | security     |        400 |
      | GSP     | support      |        400 |
      | GSP     | api,security |        400 |
      | PA1     | admin        |        200 |
      | PA1     | api          |        400 |
      | PA1     | security     |        400 |
      | PA1     | support      |        400 |
      | PA1     | api,security |        400 |
      | Privato | admin        |        200 |
      | Privato | api          |        400 |
      | Privato | security     |        400 |
      | Privato | support      |        400 |
      | Privato | api,security |        400 |

  @client_delete2
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client, richiede la cancellazione del client. L'operazione va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato 1 client "e-service"
    When l'utente richiede una operazione di cancellazione di quel client
    Then si ottiene status code 400
