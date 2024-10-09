@client_user_add
Feature: Aggiunta di un membro ad un client
  Tutti gli admin possono associare un membro ad un client

  @client_user_add1
  Scenario Outline: Un utente  admin, api, security, o support; appartenente all'ente che ha creato il client; il quale utente è già censito tra gli appartenenti all’ente ma non appartiene al client (anche se l’utente da aggiungere è l’utente stesso); associa un membro ad un client. L’operazione va a buon fine solo per il ruolo admin.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 client "CONSUMER"
    When l'utente richiede l'aggiunta di un admin di "<ente>" al client
    Then si ottiene status code <statusCode>

    Examples:
      | ente | ruolo        | statusCode |
      | GSP  | admin        |        204 |
      | GSP  | api          |        403 |
      | GSP  | security     |        403 |
      | GSP  | support      |        403 |
      | GSP  | api,security |        403 |
      | PA1  | admin        |        204 |
      | PA1  | api          |        403 |
      | PA1  | security     |        403 |
      | PA1  | support      |        403 |
      | PA1  | api,security |        403 |

  @client_user_add2
  Scenario Outline: Un utente con sufficienti permessi (admin); appartenente all'ente che ha creato il client; aggiunge al client un admin che è associato ad un altro ente. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    When l'utente richiede l'aggiunta di un admin di "PA2" al client
    Then si ottiene status code 403
