@agreement_producer_listing
Feature: Listing erogatori con richieste di fruizione
  Tutti gli utenti autorizzati di enti PA e GSP possono ottenere la lista delle richieste di fruizione dei propri e-service

  @agreement_producer_listing1
  Scenario Outline: A fronte di 3 erogatori, restituisce solo i primi 2 risultati
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "GSP" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing degli erogatori dei propri e-service limitata ai primi 2
    Then si ottiene status code 200 e la lista di 2 erogatori

    Examples: 
      | ente | ruolo        |
      | GSP  | admin        |
      | GSP  | api          |
      | GSP  | security     |
      | GSP  | api,security |
      | GSP  | support      |
      | PA1  | admin        |
      | PA1  | api          |
      | PA1  | security     |
      | PA1  | api,security |
      | PA1  | support      |

  @agreement_producer_listing2
  Scenario Outline: A fronte di 3 erogatori con i quali il fruitore ha almeno una richiesta di fruizione e una richiesta di offset 2, restituisce solo 1 risultato
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing degli erogatori dei propri e-service con offset 2
    Then si ottiene status code 200 con la corretta verifica dell'offset

  @agreement_producer_listing3
  Scenario Outline: Restituisce un insieme vuoto di erogatori per una ricerca che non porta risultati
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
     Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing degli erogatori dei propri e-service filtrando per la keyword "unknown"
    Then si ottiene status code 200 e la lista di 0 fruitori
