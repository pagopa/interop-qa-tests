#Questo test è diverso da client-key-read. L'endpoint da testare qui è: /clients/{clientId}/encoded/keys/{keyId}
@client_key_content_read
Feature: Lettura di una chiave pubblica contenuta in un client
  Tutti gli utenti autenticati possono recuperare le informazioni di una chiave pubblica contenuta in un client 

  @client_key_content_read1a
  Scenario Outline: Un utente con sufficienti permessi (admin); appartenente all'ente che ha creato il client; il quale utente è membro del client; nel quale client c'è una chiave pubblica; richiede la lettura del contenuto della chiave. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "<ente>" ha caricato una chiave pubblica in quel client
    When l'utente richiede la lettura del contenuto della chiave pubblica
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

  @client_key_content_read1b
  Scenario Outline: Un utente con sufficienti permessi (admin); appartenente all'ente che ha creato il client; il quale utente non è membro del client; nel quale client c'è una chiave pubblica; richiede la lettura del contenuto della chiave. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "security" come membro di quel client
    Given un "security" di "PA1" ha caricato una chiave pubblica in quel client
    When l'utente richiede la lettura del contenuto della chiave pubblica
    Then si ottiene status code 200

    Examples:
      | ruolo        | statusCode |
      | admin        |        200 |
      | support      |        200 |
      | api          |        403 |
      | security     |        403 |
      | api,security |        403 |

  @client_key_content_read2
  Scenario Outline: Un utente con permessi security; appartenente all'ente che ha creato il client; il quale utente è membro del client; nel quale client c'è una chiave pubblica; la quale chiave è stata o non è stata caricata dall’utente stesso; richiede la lettura del contenuto della chiave. L'operazione va a buon fine
    Given l'utente è un "sec" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "security" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica in quel client
    When l'utente richiede la lettura del contenuto della chiave pubblica
    Then si ottiene status code 200

  @client_key_content_read
  Scenario Outline: Un utente con permessi di security; il quale è appartenente all'ente al quale è associato un client; il quale utente non è membro del client; per il quale client c'è una chiave, caricata da un altro utente; richiede la lettura delle informazioni della chiave pubblica. Ottiene un errore
    Given l'utente è un "security" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica in quel client
    When l'utente richiede la lettura del contenuto della chiave pubblica
    Then si ottiene status code 403
