@tenant_e_service_consumers_listing
Feature: Listing e-service consumers
  Tutti gli utenti autenticati possono leggere la lista dei aderenti che sono iscritti ad almeno un e-service

  @tenant_e_service_consumers_listing1
  Scenario Outline: Restituisce tutti gli aderenti che sono iscritti (agreement solo in stato ACTIVE o SUSPENDED) ad almeno un e-service presente in catalogo per qualsiasi livello di permesso e tipologia di ente. NB: in realtà questa richiesta è implementata solo lato erogazione, dunque di fatto gli aderenti di enti non PA o GSP non vi accederanno, e neanche gli operatori di sicurezza di enti PA o GSP; è però una restrizione di mero utilizzo UI e non di sicurezza, dunque è indifferente se vengano imposte o meno le stesse restrizione lato backend
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing dei fruitori
    Then si ottiene status code 200 e la lista di aderenti contenente "<ente>"
    # controllare perché Privato va in errore
    Examples: 
      | ente    | ruolo        |
      | GSP     | admin        |
      | GSP     | api          |
      | GSP     | security     |
      | GSP     | support      |
      | GSP     | api,security |
      | PA1     | admin        |
      | PA1     | api          |
      | PA1     | security     |
      | PA1     | support      |
      | PA1     | api,security |
      #| Privato | admin        |
      #| Privato | api          |
      #| Privato | security     |
      #| Privato | support      |
      #| Privato | api,security |

  @tenant_e_service_consumers_listing2
  Scenario Outline: A fronte di 4 o più aderenti in db, restituisce solo i primi 2 risultati (scopo del test è verificare il corretto funzionamento del parametro limit)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing dei fruitori con limit 2
    Then si ottiene status code 200 e la lista di 2 aderenti

  @tenant_e_service_consumers_listing3
  Scenario Outline: A fronte di più aderenti in db e una richiesta con offset, restituisce il corretto numero di risultati (scopo del test è verificare il corretto funzionamento del parametro offset)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing dei fruitori con offset 2
    Then si ottiene status code 200 e il giusto numero di fruitori in base all'offset richiesto

  @tenant_e_service_consumers_listing4
  Scenario Outline: Restituisce gli aderenti che contengono la keyword "PagoPA" all'interno del nome, con ricerca case insensitive (scopo del test è verificare che funzioni il filtro q)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing dei fruitori filtrando per nome aderente "PagoPA"
    Then si ottiene status code 200 e la lista di 1 aderente

  @tenant_e_service_consumers_listing5
  Scenario Outline: Restituisce un insieme vuoto di aderenti per una ricerca che non porta risultati (scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)
    Given l'utente è un "admin" di "PA1"
    When l'utente richiede una operazione di listing dei fruitori filtrando per nome aderente "unknown"
    Then si ottiene status code 200 e la lista di 0 aderenti
