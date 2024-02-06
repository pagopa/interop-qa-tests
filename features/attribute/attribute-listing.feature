@attribute_listing

Feature: Creazione attributo certificato
  Tutti gli utenti autenticati possono leggere la lista degli attributi

  @attribute_listing1
  Scenario Outline: Restituisce gli attributi disponibili
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA1" ha già creato 5 attributi
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
    Given un "admin" di "PA1" ha già creato 19 attributi
    When l'utente richiede una operazione di listing degli attributi limitata ai primi 12 attributi
    Then si ottiene status code 200 e la lista di 12 attributi
