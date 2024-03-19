@purpose-producer-listing
Feature: Aggiornamento bozza nuova finalità in erogazione diretta

  @purpose-producer-listing1
  Scenario Outline: A fronte di 20 finalità in db, restituisce solo i primi 12 risultati (scopo del test è verificare il corretto funzionamento del parametro limit)
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "<ruolo>" di "<ente>" ha già creato 20 finalità in stato "ACTIVE" per quell'eservice
    When l'utente richiede una operazione di listing delle finalità limitata ai primi 12 attributi
    Then si ottiene status code <risultato> e la lista di 12 finalità

    Examples: 
      | ente | ruolo        | risultato |
      | PA1  | admin        |       200 |
      | PA1  | api          |       403 |
      | PA1  | security     |       403 |
      | PA1  | api,security |       403 |
      | PA1  | support      |       403 |
      | GSP  | admin        |       200 |
      | GSP  | api          |       403 |
      | GSP  | security     |       403 |
      | GSP  | api,security |       403 |
      | GSP  | support      |       403 |

  @purpose-producer-listing2
  Scenario Outline: A fronte di 15 finalità in db e una richiesta di offset 12, restituisce solo 3 risultati (scopo del test è verificare il corretto funzionamento del parametro offset)
    Given l'utente è un "admin di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 15 finalità in stato "ACTIVE" per quell'eservice
    When l'utente richiede una operazione di listing delle finalità con offset 12
    Then si ottiene status code <risultato> e la lista di 3 finalità

  @purpose-producer-listing3
  Scenario Outline: Restituisce le finalità che un erogatore si trova create dai fruitori dei propri e-service (scopo del test è verificare il corretto funzionamento del parametro producersIds)
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 2 finalità in stato "ACTIVE" per quell'eservice
    Given un "admin" di "GSP" ha già creato 2 finalità in stato "ACTIVE" per quell'eservice
    When l'utente richiede una operazione di listing delle finalità filtrata per fruitore "PA1"
    Then si ottiene status code 200 e la lista di 2 finalità
