@client_create
Feature: Creazione di un client
  Tutti gli admin possono creare un client

  @client_create1a
  Scenario Outline: Un utente con sufficienti permessi (admin); inserisce nome e descrizione, e crea un nuovo client. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede la creazione di un client "CONSUMER"
    Then si ottiene status code <statusCode>

    Examples:
      | ente | ruolo        | statusCode |
      | GSP  | admin        |        200 |
      | GSP  | api          |        403 |
      | GSP  | security     |        403 |
      | GSP  | support      |        403 |
      | GSP  | api,security |        403 |
      | PA1  | admin        |        200 |
      | PA1  | api          |        403 |
      | PA1  | security     |        403 |
      | PA1  | support      |        403 |
      | PA1  | api,security |        403 |

  @client_create1b
  Scenario Outline: Un utente con sufficienti permessi (admin); inserisce nome e descrizione, e crea un nuovo client. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede la creazione di un client "API"
    Then si ottiene status code <statusCode>

    Examples:
      | ente | ruolo        | statusCode |
      | GSP  | admin        |        200 |
      | GSP  | api          |        403 |
      | GSP  | security     |        403 |
      | GSP  | support      |        403 |
      | GSP  | api,security |        403 |
      | PA1  | admin        |        200 |
      | PA1  | api          |        403 |
      | PA1  | security     |        403 |
      | PA1  | support      |        403 |
      | PA1  | api,security |        403 |
