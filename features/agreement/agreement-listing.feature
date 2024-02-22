@agreement_listing
Feature: Listing richieste di fruizione
  Tutti gli utenti autorizzati di enti PA, GSP e privati possono ottenere la lista delle richieste di fruizione

  @agreement_listing1
  Scenario Outline: A fronte di 15 richieste di fruizione in db, restituisce solo i primi 12 risultati
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato 15 e-services in stato PUBLISHED
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing limitata alle prime 12 richieste di fruizione
    Then si ottiene status code 200 e la lista di 12 richieste di fruizione

  @agreement_listing2
  Scenario Outline: A fronte di 15 richieste di fruizione in db e una richiesta di offset 12, restituisce solo 3 risultati
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato 15 e-services in stato PUBLISHED
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing con offset 12
    Then si ottiene status code 200 e la lista di 3 richieste di fruizione

  @agreement_listing3
  Scenario Outline: Restituisce le richieste di fruizione che un erogatore si trova create dai fruitori dei propri e-service
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 5 e-services in stato PUBLISHED
    Given "PA2" ha un agreement attivo per ciascun e-service di "PA1"
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing delle richieste di fruizione ai propri e-service
    Then si ottiene status code 200 e la lista di 10 richieste di fruizione

  @agreement_listing4
  Scenario Outline: Restituisce le richieste di fruizione che un fruitore ha creato
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato 5 e-services in stato PUBLISHED
    Given "PA2" ha un agreement attivo per ciascun e-service di "PA1"
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing delle richieste di fruizione che ha creato
    Then si ottiene status code 200 e la lista di 5 richieste di fruizione

  @agreement_listing5
  Scenario Outline: Restituisce le richieste di fruizione associate ad alcuni specifici e-service
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 10 e-services in stato PUBLISHED
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    Given "PA2" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing delle richieste di fruizione per 3 specifici e-service
    Then si ottiene status code 200 e la lista di 6 richieste di fruizione

  @agreement_listing6
  Scenario Outline: Restituisce le richieste di fruizione di uno specifico fruitore che sono in uno o più specifici stati
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 10 e-services in stato PUBLISHED
    Given "GSP" ha un agreement in stato "ACTIVE" per l'e-service numero 1 di "PA1"
    Given "GSP" ha un agreement in stato "DRAFT" per l'e-service numero 2 di "PA1"
    Given "GSP" ha un agreement in stato "SUSPENDED" per l'e-service numero 3 di "PA1"
    When l'utente richiede una operazione di listing delle richieste di fruizione di "GSP" che sono in stato "ACTIVE" e "DRAFT"
    Then si ottiene status code 200 e la lista di 2 richiesta di fruizione

  @agreement_listing7
  Scenario Outline: Restituisce le richieste di fruizione di uno specifico fruitore che possono essere aggiornate ad una nuova versione di e-service
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "PA1" ha già creato 10 e-services in stato PUBLISHED
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    Given un "admin" di "PA1" ha già pubblicato una nuova versione per 5 di questi e-service
    When l'utente richiede una operazione di listing delle richieste di fruizione aggiornabili
    Then si ottiene status code 200 e la lista di 5 richieste di fruizione

  @agreement_listing8
  Scenario Outline: Restituisce un insieme vuoto di richieste di fruizione per una ricerca che non porta risultati
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 10 e-services in stato PUBLISHED
    When l'utente richiede una operazione di listing delle richieste di fruizione
    Then si ottiene status code 200 e la lista di 0 richieste di fruizione
