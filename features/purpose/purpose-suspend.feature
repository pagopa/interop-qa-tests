@purpose_suspend
Feature: Sospensione di una finalità

  @purpose_suspend1
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE, alla richiesta di sospensione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, che non coincide con l’ente erogatore, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "ente" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "<ruolo>" di "<ente>" ha già creato 1 finalità in stato "ACTIVE" per quell'e-service
    When un "<ruolo>" di "<ente>" sospende quella finalità
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | risultato |
      | PA1  | admin        |       200 |
      | PA1  | api          |       403 |
      | PA1  | security     |       403 |
      | PA1  | api,security |       403 |
      | PA1  | support      |       403 |
      | GSP  | admin        |       200 |
      | GSP  | api          |       403 |
      | GSP  | security     |       403 |
      | GSP  | api,security |       403 |
      | GSP  | support      |       403 |

  @purpose_suspend2
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE, alla richiesta di sospensione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, che non coincide con l’ente fruitore, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'e-service
    When un "admin" di "PA2" sospende quella finalità
    Then si ottiene status code 200

  @purpose_suspend3
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE, alla richiesta di sospensione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, che coincide con l’ente fruitore, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'e-service
    When un "admin" di "PA1" sospende quella finalità
    Then si ottiene status code 200

  @purpose_suspend4
  Scenario Outline: Per una finalità precedentemente creata da un fruitore, la quale è in stato NON ACTIVE (REJECTED, WAITING_FOR_APPROVAL, DRAFT, SUSPENDED, ARCHIVED), alla richiesta di sospensione da parte di un utente con sufficienti permessi (admin), ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'e-service
    When un "admin" di "PA1" sospende quella finalità
    Then si ottiene status code 400

    Examples: 
      | statoFinalita        |
      | REJECTED             |
      | WAITING_FOR_APPROVAL |
      | DRAFT                |
      | SUSPENDED            |
      | ARCHIVED             |
