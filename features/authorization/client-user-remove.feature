@client_user_remove
Feature: Rimozione di un membro da un client
  Tutti gli admin possono rimuovere un membro da un client

  @client_user_remove1
  Scenario Outline: Un utente con sufficienti permessi (admin); appartenente all'ente che ha creato il client; il quale utente è già censito tra i membri del client (anche se l’utente da rimuovere è l’utente stesso). L’operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given <ente> ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given <ente> ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given <ente> ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "admin" come membro di un client
    When l'utente richiede la rimozione di un membro dal client
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