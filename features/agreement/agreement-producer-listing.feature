@agreement_producer_listing
Feature: Listing richieste di fruizione lato erogatore
  Tutti gli utenti autorizzati di enti PA e GSP possono ottenere la lista delle richieste di fruizione dei propri e-service

  @agreement_producer_listing1
  Scenario Outline: A fronte di 4 fruitori, restituisce solo i primi 3 risultati
    Given l'utente è un "<ente>" di "<ruolo>"
    Given un "admin" di "<ente>" ha già creato 1 e-service in stato PUBLISHED
    Given "PA1" ha già una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PRIVATO" ha già una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing delle richieste di fruizione dei propri e-service limitata alle prime 3
    Then si ottiene status code 200 e la lista di 3 richieste di fruizione

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
  Scenario Outline: Restituisce i fruitori con i quali l’erogatore ha almeno una richiesta di fruizione in qualsiasi stato NON DRAFT
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 1 e-service in stato PUBLISHED
    Given "PA2" ha già una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    Given "PRIVATO" ha già una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente richiede una operazione di listing delle richieste di fruizione dei propri e-service
    Then si ottiene status code 200 e la lista di 2 richieste di fruizione

    Examples: 
      | statoAgreement |
      | PENDING        |
      | ACTIVE         |
      | SUSPENDED      |
