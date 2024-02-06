@descriptor-creation
Feature: Creazione versione di un e-service
  Gli admin e gli operatori API di enti PA e GSP possono creare una versione di un e-service

  @descriptor-creation1
  Scenario Outline: Un utente autorizzato a creare un e-service crea una versione di un e-service
    Given l'utente è un "admin" di "PA1"
    Given l'utente ha già creato un e-service
    When l'utente crea una versione in bozza per quell'e-service
    Then si ottiene status code 200

  @descriptor-creation2
  Scenario: Un utente autorizzato vuole creare una versione di e-service avendone già una in bozza
    Given l'utente è un "admin" di "PA1"
    Given l'utente ha già creato un e-service
    Given l'utente ha già creato una versione in bozza per quell'eservice
    When l'utente crea una versione in bozza per quell'e-service
    Then la creazione restituisce errore - 400
