@agreement_rejection
Feature: Rifiuto di una richiesta di fruizione

  @agreement_rejection1
  Scenario Outline: 
    Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato PENDING, alla richiesta di rifiuto con messaggio da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, va a buon fine

    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given "PA2" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    When l'utente richiede una operazione di rifiuto di quella richiesta di fruizione con messaggio
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | risultato |
      | GSP  | admin        |       200 |
      | GSP  | api          |       403 |
      | GSP  | security     |       403 |
      | GSP  | support      |       403 |
      | GSP  | api,security |       403 |
      | PA1  | admin        |       200 |
      | PA1  | api          |       403 |
      | PA1  | security     |       403 |
      | PA1  | support      |       403 |
      | PA1  | api,security |       403 |

  @agreement_rejection2
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato PENDING, alla richiesta di rifiuto SENZA messaggio da parte di un utente con sufficienti permessi dell’ente erogatore, ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    When l'utente richiede una operazione di rifiuto di quella richiesta di fruizione senza messaggio
    Then si ottiene status code 400

  @agreement_rejection3a
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato ACTIVE, SUSPENDED o ARCHIVED,alla richiesta di rifiuto con messaggio da parte di un utente con sufficienti permessi dell’ente erogatore, ottiene un errore
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente richiede una operazione di rifiuto di quella richiesta di fruizione con messaggio
    Then si ottiene status code 400

    Examples: 
      | statoAgreement |
      | ACTIVE         |
      | SUSPENDED      |
      | ARCHIVED       |

  @agreement_rejection3b
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato REJECTED,alla richiesta di rifiuto con messaggio da parte di un utente con sufficienti permessi dell’ente erogatore, ottiene un errore
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given un "admin" di "PA1" ha già creato e inviato una richiesta di fruizione per quell'e-service ed è in attesa di approvazione
    Given un "admin" di "PA2" ha già rifiutato quella richiesta di fruizione
    When l'utente richiede una operazione di rifiuto di quella richiesta di fruizione con messaggio
    Then si ottiene status code 400
    
