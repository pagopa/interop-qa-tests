@tenant_e_service_consumers_listing @PIN-5022
Feature: Listing e-service consumers
  Tutti gli utenti autenticati possono leggere la lista dei aderenti che sono iscritti ad almeno un e-service di cui sono erogatori

  @tenant_e_service_consumers_listing1a
  Scenario Outline: Restituisce tutti gli aderenti che sono iscritti (agreement solo in stato ACTIVE o SUSPENDED) ad almeno un e-service di cui sono erogatori per qualsiasi livello di permesso e tipologia di ente.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente richiede una operazione di listing dei fruitori
    Then si ottiene status code 200 e la lista di aderenti contenente "<ente>"

    Examples:
      | ente | ruolo        | statoAgreement |
      | GSP  | admin        | ACTIVE         |
      | GSP  | api          | ACTIVE         |
      | GSP  | security     | ACTIVE         |
      | GSP  | support      | ACTIVE         |
      | GSP  | api,security | ACTIVE         |
      | PA1  | admin        | ACTIVE         |
      | PA1  | api          | ACTIVE         |
      | PA1  | security     | ACTIVE         |
      | PA1  | support      | ACTIVE         |
      | PA1  | api,security | ACTIVE         |

    Examples:
      | ente | ruolo | statoAgreement |
      | PA1  | admin | SUSPENDED      |

  @tenant_e_service_consumers_listing2
  Scenario Outline: A fronte di 4 o più aderenti in db, restituisce solo i primi 2 risultati (scopo del test è verificare il corretto funzionamento del parametro limit)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing dei fruitori con limit 2
    Then si ottiene status code 200 e la lista di 2 aderenti

  @tenant_e_service_consumers_listing3
  Scenario Outline: A fronte di più aderenti in db e una richiesta con offset, restituisce il corretto numero di risultati (scopo del test è verificare il corretto funzionamento del parametro offset)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing dei fruitori con offset 2
    Then si ottiene status code 200 e il giusto numero di fruitori in base all'offset richiesto

  @tenant_e_service_consumers_listing4
  Scenario Outline: Restituisce gli aderenti che contengono la keyword "PagoPA" all'interno del nome, con ricerca case insensitive (scopo del test è verificare che funzioni il filtro q)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing dei fruitori filtrando per nome aderente "PagoPA"
    Then si ottiene status code 200 e la lista di 1 aderente

  @tenant_e_service_consumers_listing5
  Scenario Outline: Restituisce un insieme vuoto di aderenti per una ricerca che non porta risultati (scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)
    Given l'utente è un "admin" di "PA1"
    When l'utente richiede una operazione di listing dei fruitori filtrando per nome aderente "unknown"
    Then si ottiene status code 200 e la lista di 0 aderenti
