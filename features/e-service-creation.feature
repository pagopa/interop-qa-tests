Feature: Creazione e-service
  Gli admin e gli operatori API di enti PA e GSP possono creare e-service

  Scenario: Un admin di PagoPA S.p.A. crea un nuovo e-service
    Given l'utente è un "admin" di "PagoPA S.p.A."
    When l'utente crea un e-service
    Then l'e-service viene creato correttamente

  Scenario: Un admin di Sogecap crea un nuovo e-service
    Given l'utente è un "admin" di "Sogecap"
    When l'utente crea un e-service
    Then la creazione restituisce errore - "403"

  Scenario: Un operatore di sicurezza di Comune di Milano crea un nuovo e-service
    Given l'utente è un "security" di "Comune di Milano"
    When l'utente crea un e-service
    Then la creazione restituisce errore - "403"

  # Si usa l'admin di PagoPA ma va bene qualsiasi utente autorizzato a creare un e-service
  Scenario: Un utente autorizzato vuole creare due e-service con lo stesso nome
    Given l'utente è un "admin" di "PagoPA S.p.A."
    Given l'utente ha creato un e-service "e-service12"
    When l'utente crea un e-service "e-service12"
    Then la creazione restituisce errore - "409"