@purpose-producer-listing
Feature: Listing finalità lato erogatore

  @purpose-producer-listing1
  Scenario Outline: A fronte di 5 finalità in db, restituisce solo i primi 3 risultati (scopo del test è verificare il corretto funzionamento del parametro limit)
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA2" ha già creato 5 finalità in stato "ACTIVE" per quell'eservice
    When l'utente erogatore richiede una operazione di listing delle finalità limitata alle prime 3 finalità
    Then si ottiene status code <risultato> e la lista di 3 finalità

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
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA2" ha già creato 15 finalità in stato "ACTIVE" per quell'eservice
    When l'utente erogatore richiede una operazione di listing delle finalità con offset 12
    Then si ottiene status code 200 e la lista di 3 finalità

  @purpose-producer-listing3
  Scenario Outline: Restituisce le finalità che un erogatore si trova create dai fruitori dei propri e-service (scopo del test è verificare il corretto funzionamento del parametro producersIds) (nserire producerId dell'erogatore)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA2" ha già creato 2 finalità in stato "ACTIVE" per quell'eservice
    Given un "admin" di "GSP" ha già creato 2 finalità in stato "ACTIVE" per quell'eservice
    When l'utente erogatore richiede una operazione di listing delle finalità sui propri e-service
    Then si ottiene status code 200 e la lista di 4 finalità

  @purpose-producer-listing4
  Scenario Outline: Restituisce le finalità che hanno per fruitore uno o più specifici enti (scopo del test è verificare il corretto funzionamento del parametro consumerIds). NB: vengono escluse le finalità in stato DRAFT, anche qualora non fosse valorizzato il parametro states

    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA2" ha già creato 2 finalità in stato "ACTIVE" per quell'eservice
    Given un "admin" di "GSP" ha già creato 2 finalità in stato "ACTIVE" per quell'eservice
    When l'utente erogatore richiede una operazione di listing delle finalità filtrata per fruitore "PA2"
    Then si ottiene status code 200 e la lista di 2 finalità

  @purpose-producer-listing5
  Scenario Outline: Restituisce le finalità associate ad alcuni specifici e-service (scopo del test è verificare che funzioni il filtro per e-servicesIds)

    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA2" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "GSP" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    When l'utente erogatore richiede una operazione di listing delle finalità filtrata per il primo e-service
    Then si ottiene status code 200 e la lista di 1 finalità

  @purpose-producer-listing6
  Scenario Outline: Restituisce le finalità che sono in uno o più specifici stati (es. ACTIVE e SUSPENDED, scopo del test è verificare che funzioni il filtro per states)

    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA2" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "GSP" ha già creato 1 finalità in stato "SUSPENDED" per quell'eservice
    When l'utente erogatore richiede una operazione di listing delle finalità in stato "<statoFinalita>"
    Then si ottiene status code 200 e la lista di 1 finalità

    Examples: 
      | statoFinalita |
      | ACTIVE        |
      | SUSPENDED     |

  @purpose-producer-listing7
  Scenario Outline: Restituisce le finalità che contengono la keyword "test" all'interno del nome, con ricerca case insensitive (scopo del test è verificare che funzioni il filtro q)

    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA2" ha già creato 1 finalità in stato "ACTIVE" per quell'e-service contenente la keyword "test"
    When l'utente erogatore richiede una operazione di listing delle finalità filtrando per la keyword "test"
    Then si ottiene status code 200 e la lista di 1 finalità

  @purpose-producer-listing8
  Scenario Outline: Restituisce un insieme vuoto di finalità per una ricerca che non porta risultati (scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)

    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA2" ha già creato 1 finalità in stato "ACTIVE" per quell'e-service contenente la keyword "test"
    When l'utente erogatore richiede una operazione di listing delle finalità filtrando per la keyword "unknown"
    Then si ottiene status code 200 e la lista di 0 finalità
