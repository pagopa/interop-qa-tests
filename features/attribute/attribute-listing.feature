@attribute_listing @wait_for_fix
Feature: Listing attributi
  Tutti gli utenti autenticati possono leggere la lista degli attributi

  @attribute_listing1
  Scenario Outline: Restituisce gli attributi disponibili
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA1" ha già creato 5 attributi "DECLARED"
    When l'utente richiede una operazione di listing degli attributi
    Then si ottiene status code 200 e la lista di 5 attributi

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

  @attribute_listing2
  Scenario Outline: A fronte di 20 attributi in db e una richiesta di 12 attributi, restituisce solo i primi 12 risultati
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 20 attributi "DECLARED"
    When l'utente richiede una operazione di listing degli attributi limitata ai primi 12 attributi
    Then si ottiene status code 200 e la lista di 12 attributi

  @attribute_listing3
  Scenario Outline: A fronte di 15 attribute in db e un offset di 12, restituisce solo 3 risultati
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 15 attributi "DECLARED"
    When l'utente richiede una operazione di listing degli attributi con offset 12
    Then si ottiene status code 200 e la lista di 3 attributi

  @attribute_listing4
  Scenario Outline: A fronte di 5 attributi in db dei quali 3 certificati, 2 verificati e 1 dichiarato, restituisce solo i 3 certificati e i 2 verificati
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato 3 attributi "CERTIFIED"
    Given un "admin" di "PA2" ha già creato 2 attributi "VERIFIED"
    Given un "admin" di "PA2" ha già creato 1 attributo "DECLARED"
    When l'utente richiede una operatione di listing degli attributi filtrando per tipo "certificato" e "verificato"
    Then si ottiene status code 200 e la lista di 5 attributi

  @attribute_listing5
  Scenario Outline: Restituisce gli attributi in db che contengono la keyword "test" all'interno del nome con ricerca case insensitive
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 3 attributi "DECLARED"
    Given un "admin" di "PA1" ha già creato un attributo "DECLARED" con nome che contiene "test"
    When l'utente richiede una operazione di listing degli attributi filtrando per keyword "test" all'interno del nome
    Then si ottiene status code 200 e la lista di 1 attributo

  @attribute_listing6
  Scenario Outline: Restituisce un insieme vuoto di attributi per una ricerca che non porta risultati
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 3 attributi "DECLARED"
    When l'utente richiede una operazione di listing degli attributi filtrando per keyword "unknown" all'interno del nome
    Then si ottiene status code 200 e la lista di 0 attributi
