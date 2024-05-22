@client_listing
Feature: Listing client
  Tutti gli utenti autenticati possono leggere la lista dei client

  @client_listing1
  Scenario Outline: A fronte di 5 client in db, restituisce solo i primi 3 risultati
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 5 client "e-service"
    When l'utente richiede una operazione di listing dei client limitata a 3 risultati
    Then si ottiene status code 200 e la lista di 3 client

    Examples:
      | ente    | ruolo        | statusCode |
      | GSP     | admin        |        200 |
      | GSP     | api          |        400 |
      | GSP     | security     |        400 |
      | GSP     | support      |        400 |
      | GSP     | api,security |        400 |
      | PA1     | admin        |        200 |
      | PA1     | api          |        400 |
      | PA1     | security     |        400 |
      | PA1     | support      |        400 |
      | PA1     | api,security |        400 |
      | Privato | admin        |        200 |
      | Privato | api          |        400 |
      | Privato | security     |        400 |
      | Privato | support      |        400 |
      | Privato | api,security |        400 |

  @client_listing2
  Scenario Outline: A fronte di 5 client in db e una richiesta di offset 3, restituisce solo 2 risultati
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 5 client "e-service"
    When l'utente richiede una operazione di listing dei client con offset 3
    Then si ottiene status code 200 e la lista di 2 client

  @client_listing3
  Scenario Outline: Restituisce solo i client da utilizzare per gli e-service
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 3 client "e-service"
    Given "PA1" ha già creato 2 client "api"
    When l'utente richiede una operazione di listing dei client con filtro e-service
    Then si ottiene status code 200 e la lista di 3 client

  @client_listing4
  Scenario Outline: Restituisce solo i client che hanno per membro l’utente con specifico userId
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "e-service"
    Given "PA1" ha inserito l'utente con ruolo "security" come membro di un client
    Given "PA1" ha già creato 1 client "e-service"
    Given "PA1" ha inserito l'utente con ruolo "api" come membro di un client
    When l'utente richiede una operazione di listing dei client filtrando per membro utente con ruolo "security"
    Then si ottiene status code 200 e la lista di 1 client

  @client_listing5
  Scenario Outline: Restituisce i client che contengono la keyword "test" all'interno del nome, con ricerca case insensitive
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 2 client "e-service"
    Given "PA1" ha già creato 1 client "e-service" con la keyword "test" nel nome
    When l'utente richiede una operazione di listing dei client filtrando per la keyword "test"
    Then si ottiene status code 200 e la lista di 1 client

  @client_listing6
  Scenario Outline: Restituisce i client che contengono la keyword "test" all'interno del nome, con ricerca case insensitive
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "e-service"
    When l'utente richiede una operazione di listing dei client filtrando per la keyword "unknown"
    Then si ottiene status code 200 e la lista di 0 client
