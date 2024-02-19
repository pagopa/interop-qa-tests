@agreement_listing
Feature: Listing richieste di fruizione
  Tutti gli utenti autorizzati di enti PA, GSP e privati possono ottenere la lista delle richieste di fruizione

  @agreement_listing1
  Scenario Outline: A fronte di 20 richieste di fruizione in db, restituisce solo i primi 12 risultati
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato 20 e-services in catalogo in stato PUBLISHED
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing limitata alle prime 12 richieste di fruizione
    Then si ottiene status code 200 e la lista di 12 richieste di fruizione

  @agreement_listing2
  Scenario Outline: A fronte di 15 richieste di fruizione in db e una richiesta di offset 12, restituisce solo 3 risultati
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato 15 e-services in catalogo in stato PUBLISHED
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing con offset 12
    Then si ottiene status code 200 e la lista di 3 richieste di fruizione

  @agreement_listing3
  Scenario Outline: Restituisce le richieste di fruizione che un erogatore si trova create dai fruitori dei propri e-service
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 10 e-services in catalogo in stato PUBLISHED
    Given "PA2" ha un agreement attivo per ciascun e-service di "PA1"
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing delle richieste di fruizione ai propri e-service
    Then si ottiene status code 200 e la lista di 20 richieste di fruizione

  @agreement_listing4
  Scenario Outline: Restituisce le richieste di fruizione che un fruitore ha creato
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato 10 e-services in catalogo in stato PUBLISHED
    Given "PA2" ha un agreement attivo per ciascun e-service di "PA1"
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing delle richieste di fruizione che ha creato
    Then si ottiene status code 200 e la lista di 20 richieste di fruizione
   
   
  @agreement_listing5
  Scenario Outline: Restituisce le richieste di fruizione associate ad alcuni specifici e-service
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 10 e-services in catalogo in stato PUBLISHED
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    Given "PA2" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing per 3 specifici e-service
    Then si ottiene status code 200 e la lista di 6 specifiche richieste di fruizione
