@purpose_listing_producer
Feature: Listing finalità lato erogatore
  Tutti gli utenti di enti PA e GSP possono ottenere la lista di finalità di cui sono erogatori.

  @purpose_listing_producer1
  Scenario Outline: A fronte di 5 finalità in db, restituisce solo i primi 3 risultati (scopo del test è verificare il corretto funzionamento del parametro limit)
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già creato 5 finalità in stato "ACTIVE" per quell'eservice
    When l'utente erogatore richiede una operazione di listing delle finalità limitata alle prime 3 finalità
    Then si ottiene status code <risultato> e la lista di 3 finalità

    Examples: 
      | ente | ruolo        | risultato |
      | PA1  | admin        |       200 |
      | PA1  | api          |       200 |
      | PA1  | security     |       200 |
      | PA1  | api,security |       200 |
      | PA1  | support      |       200 |
      | GSP  | admin        |       200 |
      | GSP  | api          |       200 |
      | GSP  | security     |       200 |
      | GSP  | api,security |       200 |
      | GSP  | support      |       200 |

  @purpose_listing_producer2
  Scenario Outline: A fronte di 5 finalità in db e una richiesta di offset 2, restituisce solo 3 risultati
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già creato 5 finalità in stato "ACTIVE" per quell'eservice
    When l'utente erogatore richiede una operazione di listing delle finalità con offset 2
    Then si ottiene status code 200 e la lista di 3 finalità

  @purpose_listing_producer3
  Scenario Outline: Restituisce le finalità che un erogatore si trova create dai fruitori dei propri e-service (scopo del test è verificare il corretto funzionamento del parametro producersIds) (nserire producerId dell'erogatore)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già creato 2 finalità in stato "ACTIVE" per quell'eservice
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già creato 2 finalità in stato "ACTIVE" per quell'eservice
    When l'utente erogatore richiede una operazione di listing delle finalità sui propri e-service
    Then si ottiene status code 200 e la lista di 4 finalità

  @purpose_listing_producer4 @PIN-4806
  Scenario Outline: Restituisce le finalità che hanno per fruitore uno o più specifici enti (scopo del test è verificare il corretto funzionamento del parametro consumerIds). NB: vengono escluse le finalità in stato DRAFT, anche qualora non fosse valorizzato il parametro states
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già creato 2 finalità in stato "ACTIVE" per quell'eservice
    Given "PA2" ha già creato 1 finalità in stato "DRAFT" per quell'eservice
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già creato 2 finalità in stato "ACTIVE" per quell'eservice
    When l'utente erogatore richiede una operazione di listing delle finalità filtrata per fruitore "PA2"
    Then si ottiene status code 200 e la lista di 2 finalità 

  @purpose_listing_producer5
  Scenario Outline: Restituisce le finalità associate ad alcuni specifici e-service (scopo del test è verificare che funzioni il filtro per e-servicesIds)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    When l'utente erogatore richiede una operazione di listing delle finalità filtrata per il secondo e-service
    Then si ottiene status code 200 e la lista di 1 finalità

  @purpose_listing_producer6
  Scenario Outline: Restituisce le finalità che sono in uno o più specifici stati (es. ACTIVE e SUSPENDED, scopo del test è verificare che funzioni il filtro per states)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già creato 1 finalità in stato "SUSPENDED" per quell'eservice
    When l'utente erogatore richiede una operazione di listing delle finalità in stato "<statoFinalita>"
    Then si ottiene status code 200 e la lista di 1 finalità

    Examples: 
      | statoFinalita |
      | ACTIVE        |
      | SUSPENDED     |

  @purpose_listing_producer7
  Scenario Outline: Restituisce le finalità che contengono la keyword "test" all'interno del nome, con ricerca case insensitive (scopo del test è verificare che funzioni il filtro q)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già creato una finalità in stato "ACTIVE" per quell'e-service contenente la keyword "test"
    When l'utente erogatore richiede una operazione di listing delle finalità filtrando per la keyword "test"
    Then si ottiene status code 200 e la lista di 1 finalità

  @purpose_listing_producer8
  Scenario Outline: Restituisce un insieme vuoto di finalità per una ricerca che non porta risultati (scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già creato una finalità in stato "ACTIVE" per quell'e-service contenente la keyword "test"
    When l'utente erogatore richiede una operazione di listing delle finalità filtrando per la keyword "unknown"
    Then si ottiene status code 200 e la lista di 0 finalità
