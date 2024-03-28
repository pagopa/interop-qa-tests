@purpose_consumer_listing
Feature: Lista delle finalità lato fruitore
  Tutti gli utenti possono ottenere la lista delle finalità di cui sono fruitori

  @purpose_consumer_listing1 @wait_for_fix @IMN-398
  Scenario Outline: A fronte di 5 finalità in db, restituisce solo i primi 3 risultati (scopo del test è verificare il corretto funzionamento del parametro limit)
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "<ente>" ha già creato 5 finalità in stato "ACTIVE" per quell'eservice
    When l'utente fruitore richiede una operazione di listing delle finalità limitata ai primi 3 risultati
    Then si ottiene status code <risultato> e la lista di 3 finalità

    Examples: 
      | ente    | ruolo        | risultato |
      | PA1     | admin        |       200 |
      | PA1     | api          |       200 |
      | PA1     | security     |       200 |
      | PA1     | api,security |       200 |
      | PA1     | support      |       200 |
      | GSP     | admin        |       200 |
      | GSP     | api          |       200 |
      | GSP     | security     |       200 |
      | GSP     | api,security |       200 |
      | GSP     | support      |       200 |
      | Privato | admin        |       200 |
      | Privato | api          |       200 |
      | Privato | security     |       200 |
      | Privato | api,security |       200 |
      | Privato | support      |       200 |

  @purpose_consumer_listing2
  Scenario Outline: A fronte di 15 finalità in db e una richiesta di offset 12, restituisce solo 3 risultati (scopo del test è verificare il corretto funzionamento del parametro offset)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 5 finalità in stato "ACTIVE" per quell'eservice
    When l'utente fruitore richiede una operazione di listing delle finalità con offset 2
    Then si ottiene status code 200 e la lista di 3 finalità

  @purpose_consumer_listing3
  Scenario Outline: Restituisce le finalità che un fruitore ha presentato presso erogatori di e-service (scopo del test è verificare il corretto funzionamento del parametro producersIds) (restituire il listing filtrando per producerIds)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 2 finalità in stato "ACTIVE" per quell'eservice
    When l'utente fruitore richiede una operazione di listing delle sue finalità sugli e-services a cui è sottoscritto
    Then si ottiene status code 200 e la lista di 2 finalità

  @purpose_consumer_listing4
  Scenario Outline: Restituisce le finalità associate ad alcuni specifici e-service (scopo del test è verificare che funzioni il filtro per e-servicesIds)
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "GSP" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    When l'utente fruitore richiede una operazione di listing delle finalità filtrata per il secondo e-service
    Then si ottiene status code 200 e la lista di 1 finalità

  @purpose_consumer_listing5
  Scenario Outline: Restituisce le finalità che sono in uno o più specifici stati (es. ACTIVE e SUSPENDED, scopo del test è verificare che funzioni il filtro per states)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "SUSPENDED" per quell'eservice
    When l'utente fruitore richiede una operazione di listing delle finalità in stato "<statoFinalita>"
    Then si ottiene status code 200 e la lista di 1 finalità

    Examples: 
      | statoFinalita |
      | ACTIVE        |
      | SUSPENDED     |

  @purpose_consumer_listing6
  Scenario Outline: Restituisce le finalità che contengono la keyword "test" all'interno del nome, con ricerca case insensitive (scopo del test è verificare che funzioni il filtro q)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato una finalità in stato "ACTIVE" per quell'e-service contenente la keyword "test"
    When l'utente fruitore richiede una operazione di listing delle finalità filtrando per la keyword "test"
    Then si ottiene status code 200 e la lista di 1 finalità

  @purpose_consumer_listing7
  Scenario Outline: Restituisce un insieme vuoto di finalità per una ricerca che non porta risultati (scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato una finalità in stato "ACTIVE" per quell'e-service contenente la keyword "test"
    When l'utente fruitore richiede una operazione di listing delle finalità filtrando per la keyword "unknown"
    Then si ottiene status code 200 e la lista di 0 finalità
