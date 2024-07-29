@client_key_upload
Feature: Caricamento di una chiave pubblica contenuta in un client
  Tutti gli utenti autorizzati o security possono caricare una chiave pubblica di tipo RSA lunghezza 2048

  @client_key_upload1
  Scenario Outline: Un utente admin o security; appartenente all'ente che ha creato il client; il quale utente è membro del client; richiede il caricamento di una chiave pubblica di tipo RSA, lunghezza 2048. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "<ruolo>" come membro di quel client
    When l'utente richiede il caricamento di una chiave pubblica di tipo "RSA"
    Then si ottiene status code <statusCode>

    Examples:
      | ente | ruolo        | statusCode |
      | GSP  | admin        |        204 |
      | GSP  | security     |        204 |
      | GSP  | support      |        403 |
      | GSP  | api,security |        204 |
      | PA1  | admin        |        204 |
      | PA1  | security     |        204 |
      | PA1  | support      |        403 |
      | PA1  | api,security |        204 |

  @client_key_upload2
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente NON è membro del client; richiede il caricamento di una chiave pubblica di tipo RSA, lunghezza 2048. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    When l'utente richiede il caricamento di una chiave pubblica di tipo "RSA"
    Then si ottiene status code 403

  @client_key_upload3
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente è membro del client; richiede il caricamento di una chiave pubblica di tipo NON-RSA, lunghezza 2048. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    When l'utente richiede il caricamento di una chiave pubblica di tipo "NON-RSA" di lunghezza 2048
    Then si ottiene status code 400

  @client_key_upload4 @wait_for_fix @PIN-5143
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente è membro del client; richiede il caricamento di una chiave pubblica di tipo RSA, lunghezza inferiore a 2048. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    When l'utente richiede il caricamento di una chiave pubblica di tipo "RSA" di lunghezza 1024
    Then si ottiene status code 400

  @client_key_upload5
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente è membro del client; richiede il caricamento di una chiave pubblica di tipo RSA, lunghezza 2048; alla quale vengono rimossi i delimitatori di inizio e fine (---BEGIN PUBLIC KEY---, ---END PUBLIC KEY---). Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    When l'utente richiede il caricamento di una chiave pubblica di tipo "RSA" di lunghezza 2048 senza i delimitatori di inizio e fine
    Then si ottiene status code 400

  @client_key_upload6
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente è membro del client; richiede il caricamento di una chiave pubblica di tipo RSA, lunghezza 2048; Per poi richiedere per la seconda volta il caricamento della stessa. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede il caricamento di una chiave pubblica di tipo "RSA" di lunghezza 2048 con lo stesso kid
    Then si ottiene status code 409
