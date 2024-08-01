@client_delete
Feature: Cancellazione client
  Tutti gli utenti autorizzati possono cancellare il proprio client

  @client_delete1
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client, richiede la cancellazione del client. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 client "CONSUMER"
    When l'utente richiede una operazione di cancellazione di quel client
    Then si ottiene status code <statusCode>

    Examples:
      | ente    | ruolo        | statusCode |
      | GSP     | admin        |        204 |
      | GSP     | api          |        403 |
      | GSP     | security     |        403 |
      | GSP     | support      |        403 |
      | GSP     | api,security |        403 |
      | PA1     | admin        |        204 |
      | PA1     | api          |        403 |
      | PA1     | security     |        403 |
      | PA1     | support      |        403 |
      | PA1     | api,security |        403 |
      | Privato | admin        |        204 |
      | Privato | api          |        403 |
      | Privato | security     |        403 |
      | Privato | support      |        403 |
      | Privato | api,security |        403 |

  @client_delete2
  Scenario Outline: Un utente con sufficienti permessi (admin) non associato all’ente che ha creato il client, richiede la cancellazione del client. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato 1 client "CONSUMER"
    When l'utente richiede una operazione di cancellazione di quel client
    Then si ottiene status code 403
