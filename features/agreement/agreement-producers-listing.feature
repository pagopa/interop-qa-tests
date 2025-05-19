@agreement_producers_listing
Feature: Listing erogatori con richieste di fruizione
  Tutti gli utenti autorizzati possono ottenere la lista degli erogatori degli e-service per cui hanno una richiesta di fruizione

  @agreement_producers_listing1
  Scenario Outline: A fronte di 3 erogatori, restituisce solo i primi 2 risultati
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing degli erogatori degli e-service per cui ha una richiesta di fruizione limitata ai primi 2
    Then si ottiene status code 200 e la lista di 2 erogatori

    Examples: 
      | ente    | ruolo        |
      | GSP     | admin        |
      | GSP     | api          |
      | GSP     | security     |
      | GSP     | api,security |
      | GSP     | support      |
      | PA1     | admin        |
      | PA1     | api          |
      | PA1     | security     |
      | PA1     | api,security |
      | PA1     | support      |
      | Privato | admin        |
      | Privato | api          |
      | Privato | security     |
      | Privato | support      |
      | Privato | api,security |

  @agreement_producers_listing2
  Scenario Outline: A fronte di 3 erogatori con i quali il fruitore ha almeno una richiesta di fruizione e una richiesta di offset 2, restituisce solo 1 risultato
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing degli erogatori degli e-service per cui ha una richiesta di fruizione con offset 2
    Then si ottiene status code 200 con la corretta verifica dell'offset

  @agreement_producers_listing3
  Scenario Outline: Restituisce gli erogatori il cui nome dell’ente contiene la keyword "Comune di Milano" all'interno del nome, con ricerca case insensitive. In questo scenario il nome di PA1 è "Comune di Milano"
    Given l'utente è un "admin" di "GSP"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing degli erogatori degli e-service per cui ha una richiesta di fruizione filtrando per la keyword "Comune di Milano"
    Then si ottiene status code 200 e la lista di 1 erogatore

  @agreement_producers_listing4
  Scenario Outline: Restituisce un insieme vuoto di erogatori per una ricerca che non porta risultati
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing degli erogatori degli e-service per cui ha una richiesta di fruizione filtrando per la keyword "unknown"
    Then si ottiene status code 200 e la lista di 0 erogatori
