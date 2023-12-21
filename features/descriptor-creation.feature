Feature: Creazione versione di un e-service
  Gli admin e gli operatori API di enti PA e GSP possono creare una versione di un e-service

  Scenario Outline: Un utente autorizzato a creare un e-service crea una versione di un e-service
    Given l'utente è un "<ruolo>" di "<ente>"
    Given l'utente ha già creato un e-service
    When l'utente crea una versione di un e-service
    Then si ottiene status code "<risultato>"

      Examples:
    | ente               | ruolo          | risultato |
    | GSP                | admin          | 200       |
    #| GSP                | api            | 200       |
    #| GSP                | api,security   | 200       |
    #| PA1                | admin          | 200       |
    #| PA1                | api            | 200       |
    #| PA1                | api,security   | 200       |

# Si usa l'admin di PagoPA ma va bene qualsiasi utente autorizzato a creare un e-service
  Scenario: Un utente autorizzato vuole creare una versione di e-service avendone già una in bozza
    Given l'utente è un "admin" di "GSP"
    Given l'utente ha già creato una versione di e-service in bozza
    When l'utente crea una versione di un e-service
    Then si ottiene status code "400"
