@agreement_producer_listing
Feature: Listing erogatori con richieste di fruizione
  Tutti gli utenti autorizzati di enti PA e GSP possono ottenere la lista delle richieste di fruizione dei propri e-service

  @agreement_producer_listing1
  Scenario Outline: A fronte di 4 fruitori, restituisce solo i primi 3 risultati
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "Privato" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing dei fruitori dei propri e-service limitata ai primi 3
    Then si ottiene status code 200 e la lista di 3 fruitori

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
  Scenario Outline: A fronte di 4 fruitori con i quali l’erogatore ha almeno una richiesta di fruizione e una richiesta di offset 2, restituisce solo 2 risultati
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "Privato" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing dei fruitori dei propri e-service con offset 2
    Then si ottiene status code 200 con la corretta verifica dell'offset

  @agreement_producer_listing3
  Scenario Outline: Restituisce un insieme vuoto di fruitori per una ricerca che non porta risultati
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing dei fruitori dei propri e-service filtrando per la keyword "unknown"
    Then si ottiene status code 200 e la lista di 0 fruitori
