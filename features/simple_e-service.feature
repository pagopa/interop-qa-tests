Feature: Creazione di un nuovo e-service
  Everybody wants to know when it's Friday

  Scenario: L'eservice non esisteva
    When creo un e-service "e-service4"
    Then l'e-service viene creato correttamente

  Scenario: Esiste già un e-service con lo stesso nome
    Given esiste un e-service titolo "e-service5"
    When creo un e-service "e-service5"
    Then la creazione restituisce errore - 409 Conflict