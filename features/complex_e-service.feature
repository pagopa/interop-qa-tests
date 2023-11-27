Feature: Creazione di un nuovo e-service
  Everybody wants to know when it's Friday

  Scenario Outline: L'eservice non esisteva
    Given un utente con ruolo "<ruolo>" dell'ente "<ente>"
    When creo un e-service
    Then si ottiene status code "<risultato>"

  Examples:
    | ente  | ruolo         | risultato |
    | PA    | admin         | 200       |
    | PA    | api           | 200       |
    | PA    | security      | 403       |