@client_key_delete
Feature: Cancellazione delle chiavi di un client
  Tutti gli utenti admin possono cancellare le chiavi del proprio client


  @client_key_delete1
  Scenario Outline: Un utente con sufficienti permessi (admin); appartenente all'ente che ha creato il client; il quale utente è membro del client; nel quale client c'è una chiave pubblica; richiede la cancellazione della chiave. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "admin" come membro di un client
    Given un "admin" di "<ente>" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
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


  @client_key_delete2
  Scenario Outline: Un utente admin, api o security, appartenente all'ente che ha creato il client, il quale utente NON è membro del client, nel quale client c'è una chiave pubblica, richiede la cancellazione della chiave. L'operazione va a buon fine solo per il ruolo admin
    Given l'utente è un "<ruolo>" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code <statusCode>

    Examples:
      | ruolo    | statusCode |
      | admin    |        204 |
      | api      |        403 |
      | security |        403 |


  @client_key_delete3
  Scenario Outline: Un utente con permessi security; appartenente all'ente che ha creato il client; il quale utente NON è membro del client; nel quale client c'è una chiave pubblica; la quale chiave è caricata da un altro utente; richiede la cancellazione della chiave. Ottiene un errore
    Given l'utente è un "security" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code 403


  @client_key_delete4
  Scenario Outline: Un utente con permessi security; appartenente all'ente che ha creato il client; il quale utente NON è membro del client; nel quale client c'è una chiave pubblica; la quale chiave è caricata da questo utente; richiede la cancellazione della chiave. L’operazione va a buon fine
    Given l'utente è un "security" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given un "security" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code 204
