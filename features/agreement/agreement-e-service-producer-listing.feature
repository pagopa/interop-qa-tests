@agreement_e_service_producer_listing
Feature: Listing e-eservice con agreement attivo
  Tutti gli utenti autorizzati di enti PA, GSP possono ottenere la lista degli e-service con la quale hanno almeno una richiesta di fruizione attiva

  @agreement_e_service_producer_listing1
  Scenario Outline: Restituisce gli e-service per i quali l’erogatore ha almeno una richiesta di fruizione in stato NON DRAFT da parte dei fruitori
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "<ruolo>" di "<ente>" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "<ruolo>" di "<ente>" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "PA1" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    When l'utente richiede una operazione di listing degli e-services che hanno una richiesta di fruizione attiva
    Then si ottiene status code 200 e la lista di 1 e-service

    Examples: 
      | ente    | ruolo        | risultato |
      | GSP     | admin        |       200 |
      | GSP     | api          |       200 |
      | GSP     | security     |       200 |
      | GSP     | support      |       200 |
      | GSP     | api,security |       200 |
      | PA1     | admin        |       200 |
      | PA1     | api          |       200 |
      | PA1     | security     |       200 |
      | PA1     | support      |       200 |
      | PA1     | api,security |       200 |
      | Privato | admin        |       200 |
      | Privato | api          |       200 |
      | Privato | security     |       200 |
      | Privato | support      |       200 |
      | Privato | api,security |       200 |

  @agreement_e_service_producer_listing2
  Scenario Outline: A fronte di 5 e-service, restituisce solo i primi 3 risultati
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 5 e-services
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing degli e-services che hanno una richiesta di fruizione attiva limitata ai primi 3 e-services
    Then si ottiene status code 200 e la lista di 3 e-service

  @agreement_e_service_producer_listing3
  Scenario Outline: A fronte di 5 e-service in db e una richiesta di offset 2, restituisce solo 3 risultati 
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 5 e-services
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing degli e-services che hanno una richiesta di fruizione attiva con offset 2
    Then si ottiene status code 200 e la lista di 3 e-service

  @agreement_e_service_producer_listing4
  Scenario Outline: Restituisce gli e-service il cui nome contiene la keyword "test" all'interno del nome, con ricerca case insensitive
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 2 e-services
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato un e-service contenente la keyword "test"
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing degli e-services che hanno una richiesta di fruizione attiva filtrando per la keyword "Test"
    Then si ottiene status code 200 e la lista di 1 e-service

  @agreement_e_service_producer_listing5
  Scenario Outline: Restituisce un insieme vuoto di e-service per una ricerca che non porta risultati
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 2 e-services
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing degli e-services che hanno una richiesta di fruizione attiva filtrando per la keyword "unknown"
    Then si ottiene status code 200 e la lista di 0 e-service
