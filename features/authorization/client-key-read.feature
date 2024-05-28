@client_key_read
Feature: Lettura di una chiave pubblica contenuta in un client
  Tutti gli utenti autenticati possono recuperare le informazione di una chiave pubblica contenuta in un client 

  @client_key_read1
  Scenario Outline: Un utente con sufficienti permessi (admin); il quale è appartenente all’ente al quale è associato un client; il quale utente non è membro del client; per il quale client c'è una chiave, caricata da un altro utente; richiede la lettura delle informazioni della chiave pubblica. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "<ente>" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given un "security" di "<ente>" ha caricato una chiave pubblica nel client
    When l'utente richiede la lettura della chiave pubblica
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

  @client_key_read2
  Scenario Outline: Un utente con permessi di security; il quale è appartenente all'ente al quale è associato un client; il quale utente è membro del client; per il quale client c'è una chiave, caricata da un altro utente; richiede la lettura delle informazioni della chiave pubblica. Ottiene un errore. NB: da verificare, non sono sicuro. I security forse si comportano come gli admin per i client ai quali sono associati
    Given l'utente è un "security" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
        Given "PA1" ha già inserito l'utente con ruolo "security" come membro di un client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la lettura della chiave pubblica
    Then si ottiene status code 200

  @client_key_read3
  Scenario Outline: Un utente con permessi di security; il quale è appartenente all'ente al quale è associato un client; il quale utente non è membro del client; per il quale client c'è una chiave, caricata da un altro utente; richiede la lettura delle informazioni della chiave pubblica. Ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "WAITING_FOR_APPROVAL" per quell'eservice
    Given "PA2" ha già rifiutato l'aggiornamento della stima di carico per quella finalità
    Given "PA1" ha già creato 1 client "CONSUMER"
    When l'utente richiede l'associazione della finalità al client
    Then si ottiene status code 400

  