@client_listing
Feature: Listing client
  Tutti gli utenti autenticati possono leggere la lista dei client

  @client_listing1
  Scenario Outline: A fronte di una richiesta di listing restituisce 200 per tutti i ruoli di API
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede una operazione di listing dei client
    Then si ottiene status code <statusCode>

    Examples:
      | ente    | ruolo        | statusCode |
      | GSP     | admin        |        200 |
      | GSP     | api          |        403 |
      | GSP     | security     |        200 |
      | GSP     | support      |        200 |
      | GSP     | api,security |        200 |
      | PA1     | admin        |        200 |
      | PA1     | api          |        403 |
      | PA1     | security     |        200 |
      | PA1     | support      |        200 |
      | PA1     | api,security |        200 |
      | Privato | admin        |        200 |
      | Privato | api          |        403 |
      | Privato | security     |        200 |
      | Privato | support      |        200 |
      | Privato | api,security |        200 |

  @client_listing2
  Scenario Outline: A fronte di 5 client in db, restituisce solo i primi 3 risultati
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 5 client "CONSUMER"
    When l'utente richiede una operazione di listing dei client limitata a 3 risultati
    Then si ottiene status code 200 e la lista di 3 client

  @client_listing3
  Scenario Outline: A fronte di 5 client in db e una richiesta di offset 3, restituisce solo 2 risultati
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 5 client "CONSUMER"
    When l'utente richiede una operazione di listing dei client con offset 3
    Then si ottiene status code 200 e la lista di 2 client

  @client_listing4
  Scenario Outline: Restituisce solo i client da utilizzare per gli e-service
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 3 client "CONSUMER"
    Given "PA1" ha già creato 2 client "API"
    When l'utente richiede una operazione di listing dei client con filtro "CONSUMER"
    Then si ottiene status code 200 e la lista di 3 client

  @client_listing5
  Scenario Outline: Restituisce solo i client che hanno per membro l’utente con specifico userId
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "security" come membro di un client
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di un client
    When l'utente richiede una operazione di listing dei client filtrando per membro utente con ruolo "security"
    Then si ottiene status code 200 e la lista di 1 client

  @client_listing6
  Scenario Outline: Restituisce i client che contengono la keyword "test" all'interno del nome, con ricerca case insensitive
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 2 client "CONSUMER"
    Given "PA1" ha già creato 1 client "CONSUMER" con la keyword "test" nel nome
    When l'utente richiede una operazione di listing dei client filtrando per la keyword "test"
    Then si ottiene status code 200 e la lista di 1 client

  @client_listing7
  Scenario Outline: Restituisce un insieme vuoto di client per una ricerca che non porta risultati
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    When l'utente richiede una operazione di listing dei client filtrando per la keyword "unknown"
    Then si ottiene status code 200 e la lista di 0 client

  @client_listing8
  Scenario Outline: A fronte di una richiesta di listing da parte di un ente, con client creati da altri enti, restituisce 200 e la lista di 0 client
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato 1 client "CONSUMER"
    Given "GSP" ha già creato 1 client "CONSUMER"
    Given "Privato" ha già creato 1 client "CONSUMER"
    When l'utente richiede una operazione di listing dei client
    Then si ottiene status code 200 e la lista di 0 client