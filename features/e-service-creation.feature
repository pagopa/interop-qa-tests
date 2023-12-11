Feature: Creazione e-service
  Gli admin e gli operatori API di enti PA e GSP possono creare e-service

  Scenario Outline: Un utente con sufficienti permessi di un ente autorizzato crea un e-service
    Given l'utente è un "<ruolo>" di "<ente>"
    When creo un e-service
    Then si ottiene status code "<risultato>"

  Examples:
    | ente               | ruolo      | risultato |
    | PagoPA             | admin      | 200       |
    | PagoPA             | api        | 200       |
    | PagoPA             | security   | 403       |
    | PagoPA             | support    | 403       |
    | Sogecap            | admin      | 403       |
    | Sogecap            | api        | 403       |
    | Sogecap            | security   | 403       |
    | Sogecap            | support    | 403       |
    | Comune di Milano   | admin      | 200       |
    | Comune di Milano   | api        | 200       |
    | Comune di Milano   | security   | 403       |
    | Comune di Milano   | support    | 403       |


  # Si usa l'admin di PagoPA ma va bene qualsiasi utente autorizzato a creare un e-service
  Scenario: Un utente autorizzato vuole creare due e-service con lo stesso nome
    Given l'utente è un "admin" di "PagoPA S.p.A."
    Given l'utente ha creato un e-service "e-service12"
    When l'utente crea un e-service "e-service12"
    Then la creazione restituisce errore - "409"