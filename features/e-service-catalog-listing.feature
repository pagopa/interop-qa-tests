@catalog
Feature: Listing catalogo e-services
  Tutti gli utenti autenticati di enti PA, GSP e privati possono ottenere la lista di e-services

  Scenario Outline: Un utente con sufficienti permessi di un ente autorizzato crea un e-service
    Given l'utente è un "<ruolo>" di "<ente>"
    Given esistono più di 12 e-services in catalogo in stato Published o Suspended
    When l'utente richiede una operazione di listing limitata ai primi 12
    Then si ottiene status code "<risultato>" e la lista di 12 e-services

      Examples:
      | ente               | ruolo          | risultato |
      | GSP                | admin          | 200       |
      #| GSP                | api            | 200       |
      #| GSP                | security       | 200       |
      #| GSP                | api,security   | 200       |
      #| GSP                | support        | 200       |
      #| Privato            | admin          | 200       |
      #| Privato            | api            | 200       |
      #| Privato            | security       | 200       |
      #| Privato            | api,security   | 200       |
      #| Privato            | support        | 200       |
      #| PA1                | admin          | 200       |
      #| PA1                | api            | 200       |
      #| PA1                | security       | 200       |
      #| PA1                | api,security   | 200       |
      #| PA1                | support        | 200       |
