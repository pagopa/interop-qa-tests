@agreement_listing
Feature: Listing richieste di fruizione
  Tutti gli utenti autorizzati di enti PA, GSP e privati possono ottenere la lista delle richieste di fruizione
  NB: Gli e-service creati devono essere il minimo numero sufficiente per far passare il test, in caso contrario il sistema potrebbe sovraccaricarsi e non rispondere nei tempi attesi

  @agreement_listing1 @no-parallel
  Scenario Outline: A fronte di 5 richieste di fruizione in db, restituisce solo i primi 3 risultati
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA1" ha già creato e pubblicato 5 e-services
    Given "<ente>" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing limitata alle prime 3 richieste di fruizione
    Then si ottiene status code 200 e la lista di 3 richieste di fruizione

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
      | Privato | admin        |
      | Privato | api          |
      | Privato | security     |
      | Privato | support      |
      | Privato | api,security |

  @agreement_listing2
  Scenario Outline: A fronte di 5 richieste di fruizione in db e una richiesta di offset 3, restituisce solo 2 risultati
    Given l'utente è un "admin" di "PA2"
    Given "PA1" ha già creato e pubblicato 5 e-services
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing con offset 3
    Then si ottiene status code 200 e la lista di 2 richieste di fruizione

  @agreement_listing3 @no-parallel
  Scenario Outline: Restituisce le richieste di fruizione che un erogatore si trova create dai fruitori dei propri e-service
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 5 e-services
    Given "PA2" ha un agreement attivo per ciascun e-service di "PA1"
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing delle richieste di fruizione ai propri e-service
    Then si ottiene status code 200 e la lista di 10 richieste di fruizione

  @agreement_listing4
  Scenario Outline: Restituisce le richieste di fruizione che un fruitore ha creato
    Given l'utente è un "admin" di "PA2"
    Given "PA1" ha già creato e pubblicato 5 e-services
    Given "PA2" ha un agreement attivo per ciascun e-service di "PA1"
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing delle richieste di fruizione che ha creato
    Then si ottiene status code 200 e la lista di 5 richieste di fruizione

  @agreement_listing5
  Scenario Outline: Restituisce le richieste di fruizione associate ad alcuni specifici e-service
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 5 e-services
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    Given "PA2" ha un agreement attivo per ciascun e-service di "PA1"
    When l'utente richiede una operazione di listing delle richieste di fruizione per 3 specifici e-service
    Then si ottiene status code 200 e la lista di 6 richieste di fruizione

  @agreement_listing6
  Scenario Outline: Restituisce le richieste di fruizione di uno specifico fruitore che sono in uno o più specifici stati
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 5 e-services
    Given "GSP" ha un agreement in stato "ACTIVE" per l'e-service numero 1 di "PA1"
    Given "GSP" ha un agreement in stato "DRAFT" per l'e-service numero 2 di "PA1"
    Given "GSP" ha un agreement in stato "SUSPENDED" per l'e-service numero 3 di "PA1"
    When l'utente richiede una operazione di listing delle richieste di fruizione di "GSP" che sono in stato "ACTIVE" e "DRAFT"
    Then si ottiene status code 200 e la lista di 2 richiesta di fruizione

  @agreement_listing7
  Scenario Outline: Restituisce le richieste di fruizione di uno specifico fruitore che possono essere aggiornate ad una nuova versione di e-service
    Given l'utente è un "admin" di "GSP"
    Given "PA1" ha già creato e pubblicato 5 e-services
    Given "GSP" ha un agreement attivo per ciascun e-service di "PA1"
    Given "PA1" ha già pubblicato una nuova versione per 2 di questi e-service
    When l'utente richiede una operazione di listing delle richieste di fruizione aggiornabili
    Then si ottiene status code 200 e la lista di 2 richieste di fruizione

  @agreement_listing8
  Scenario Outline: Restituisce un insieme vuoto di richieste di fruizione per una ricerca che non porta risultati
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 2 e-services
    When l'utente richiede una operazione di listing delle richieste di fruizione
    Then si ottiene status code 200 e la lista di 0 richieste di fruizione
