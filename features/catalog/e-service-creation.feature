@eservice_creation
Feature: Creazione e-service
  Gli admin e gli operatori API di enti PA e GSP possono creare e-service

  @eservice_creation1
  Scenario Outline: Un utente con sufficienti permessi di un ente autorizzato crea un e-service
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente crea un e-service
    Then si ottiene status code <risultato>

    Examples: 
      | ente    | ruolo        | risultato |
      | GSP     | admin        |       200 |
      | GSP     | api          |       200 |
      | GSP     | security     |       403 |
      | GSP     | api,security |       200 |
      | GSP     | support      |       403 |
      | Privato | admin        |       403 |
      | Privato | api          |       403 |
      | Privato | security     |       403 |
      | Privato | api,security |       403 |
      | Privato | support      |       403 |
      | PA1     | admin        |       200 |
      | PA1     | api          |       200 |
      | PA1     | security     |       403 |
      | PA1     | api,security |       200 |
      | PA1     | support      |       403 |

  @eservice_creation2
  Scenario: Un utente autorizzato vuole creare due e-service con lo stesso nome
    Given l'utente è un "admin" di "PA1"
    Given l'utente ha già creato un e-service contenente anche il primo descrittore
    When l'utente crea un e-service con lo stesso nome
    Then si ottiene status code 409
