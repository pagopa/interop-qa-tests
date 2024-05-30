@client_key_upload
Feature: Caricamento di una chiave pubblica contenuta in un client
  Tutti gli utenti admin o security possono caricare una chiave pubblica di tipo risultati

  @client_key_upload1
  Scenario Outline: Un utente admin o security; appartenente all'ente che ha creato il client; il quale utente è membro del client; richiede il caricamento di una chiave pubblica di tipo RSA, lunghezza 2048. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "admin" come membro di quel client
    When l'utente richiede il caricamento di una chiave pubblica di tipo "RSA"
    Then si ottiene status code <statusCode>

    Examples:
      | ente | ruolo        | statusCode |
      | GSP  | admin        |        200 |
      | GSP  | api          |        403 |
      | GSP  | security     |        200 |
      | GSP  | support      |        200 |
      | GSP  | api,security |        200 |
      | PA1  | admin        |        200 |
      | PA1  | api          |        403 |
      | PA1  | security     |        200 |
      | PA1  | support      |        200 |
      | PA1  | api,security |        200 |

  @client_key_upload2
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente NON è membro del client; richiede il caricamento di una chiave pubblica di tipo RSA, lunghezza 2048. Ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    When l'utente richiede il caricamento di una chiave pubblica di tipo "RSA"
    Then si ottiene status code 400

  @client_key_upload3
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente è membro del client; richiede il caricamento di una chiave pubblica di tipo NON RSA, lunghezza 2048. Ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "admin" come membro di quel client
    When l'utente richiede il caricamento di una chiave pubblica di tipo "non-RSA"
    Then si ottiene status code 400

  