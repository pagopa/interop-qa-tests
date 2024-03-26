@agreement_e_service_consumer_listing
Feature: Listing e-service con richieste di fruizione attive lato fruitore
  Tutti gli utenti autorizzati di enti PA, GSP possono ottenere la lista degli e-service con la quale hanno almeno una richiesta di fruizione attiva

  @agreement_e_service_consumer_listing1
  Scenario Outline: Restituisce gli e-service per i quali il fruitore ha almeno una richiesta di fruizione in qualsiasi stato
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato e pubblicato 2 e-services
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per ognuno di quegli e-services
    When l'utente richiede una operazione di listing degli e-services per cui ha una richiesta di fruizione
    Then si ottiene status code 200 e la lista di 2 e-services

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

  @agreement_e_service_consumer_listing2
  Scenario Outline: A fronte di 5 e-service, restituisce solo i primi 3 risultati
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato e pubblicato 5 e-services
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per ognuno di quegli e-services
    When l'utente richiede una operazione di listing degli e-services per cui ha una richiesta di fruizione limitata a 3
    Then si ottiene status code 200 e la lista di 3 e-service

  @agreement_e_service_consumer_listing3
  Scenario Outline: A fronte di 5 e-service in db e una richiesta di offset 2, restituisce solo 3 risultati
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato e pubblicato 5 e-services
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per ognuno di quegli e-services
    When l'utente richiede una operazione di listing degli e-services per cui ha una richiesta di fruizione con offset 2
    Then si ottiene status code 200 e la lista di 3 e-service

  @agreement_e_service_consumer_listing4
  Scenario Outline: Restituisce gli e-service il cui nome contiene la keyword "test" all'interno del nome, con ricerca case insensitive
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato e pubblicato un e-service contenente la keyword "test"
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing degli e-services per cui ha una richiesta di fruizione con keyword "test"
    Then si ottiene status code 200 e la lista di 1 e-service

  @agreement_e_service_consumer_listing5
  Scenario Outline: Restituisce un insieme vuoto di e-service per una ricerca che non porta risultati (es. stringa “disosfdio sjfjods” all’interno del nome. Scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato e pubblicato un e-service contenente la keyword "test"
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di listing degli e-services per cui ha una richiesta di fruizione con keyword "unknown"
    Then si ottiene status code 200 e la lista di 0 e-service
