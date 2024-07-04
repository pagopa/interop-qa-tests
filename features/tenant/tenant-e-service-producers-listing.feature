@tenant_e_service_producers_listing @PIN-5022
Feature: Listing e-service producers
  Tutti gli utenti autenticati possono leggere la lista dei aderenti che erogano almeno un e-service

  @tenant_e_service_producers_listing1
  Scenario Outline: Restituisce tutti gli erogatori di e-service presenti in catalogo, compresi anche quelli in stato DRAFT, per qualsiasi livello di permesso e tipologia di ente.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato e pubblicato 1 e-service
    When l'utente richiede una operazione di listing degli erogatori
    Then si ottiene status code 200 e la lista di aderenti contenente "<ente>"
    Examples: 
      | ente    | ruolo        |
      | GSP     | admin        |
      | GSP     | api          |
      | GSP     | security     |
      | GSP     | support      |
      | GSP     | api,security |
      | PA2     | admin        |
      | PA1     | api          |
      | PA1     | security     |
      | PA1     | support      |
      | PA1     | api,security |

  @tenant_e_service_producers_listing2
  Scenario Outline: A fronte di 4 o più aderenti in db, restituisce solo i primi 2 risultati (scopo del test è verificare il corretto funzionamento del parametro limit)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "GSP" ha già creato e pubblicato 1 e-service
    When l'utente richiede una operazione di listing degli erogatori con limit 2
    Then si ottiene status code 200 e la lista di 2 aderenti

  @tenant_e_service_producers_listing3
  Scenario Outline: A fronte di più aderenti in db e una richiesta con offset, restituisce il corretto numero di risultati (scopo del test è verificare il corretto funzionamento del parametro offset)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "GSP" ha già creato e pubblicato 1 e-service
    When l'utente richiede una operazione di listing degli erogatori con offset 2
    Then si ottiene status code 200 e il giusto numero di erogatori in base all'offset richiesto

  @tenant_e_service_producers_listing4
  Scenario Outline: Restituisce gli aderenti che contengono la keyword "PagoPA" all'interno del nome, con ricerca case insensitive (scopo del test è verificare che funzioni il filtro q)
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    When l'utente richiede una operazione di listing degli erogatori filtrando per nome aderente "PagoPA"
    Then si ottiene status code 200 e la lista di 1 aderente

  @tenant_e_service_producers_listing5
  Scenario Outline: Restituisce un insieme vuoto di aderenti per una ricerca che non porta risultati (scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)
    Given l'utente è un "admin" di "PA1"
    When l'utente richiede una operazione di listing degli erogatori filtrando per nome aderente "unknown"
    Then si ottiene status code 200 e la lista di 0 aderenti
