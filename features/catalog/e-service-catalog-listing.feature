@catalog
Feature: Listing catalogo e-services
  Tutti gli utenti autenticati di enti PA, GSP e privati possono ottenere la lista di e-services

  Scenario Outline: Un utente richiede la lista degli eservices
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "GSP" ha già creato più di 12 e-services in catalogo in stato Published o Suspended
    When l'utente richiede una operazione di listing limitata ai primi 12
    Then si ottiene status code "<risultato>" e la lista di 12 e-services

    Examples: 
      | ente           | ruolo | risultato |
      | GSP            | admin |       200 |
      | ComuneDiMilano | admin |       200 |
      | AgID           | admin |       200 |
      | Privato        | admin |       200 |

  Scenario Outline: Un utente richiede la lista degli eservices di uno specifico erogatore
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "ComuneDiMilano" ha già creato più di 12 e-services in catalogo in stato Published o Suspended
    Given un "admin" di "AgID" ha già creato più di 12 e-services in catalogo in stato Published o Suspended
    When l'utente richiede una operazione di listing limitata ai primi 12 e-services dell'erogatore "ComuneDiMilano"
    Then si ottiene status code "<risultato>" e la lista degli eservices dell'erogatore specificato

    Examples: 
      | ente           | ruolo | risultato |
      | GSP            | admin |       200 |
      | ComuneDiMilano | admin |       200 |
      | AgID           | admin |       200 |
      | Privato        | admin |       200 |
