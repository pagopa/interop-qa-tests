@purpose_suspend
Feature: Sospensione di una finalità
  Tutti gli utenti admin possono sospendere una propria finalità

  @purpose_suspend1
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE, alla richiesta di sospensione da parte di un utente con sufficienti permessi dell’ente fruitore, che non coincide con l’ente erogatore, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "<ente>" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    When l'utente sospende quella finalità in stato "ACTIVE"
    Then si ottiene status code <risultato>

    Examples: 
      | ente    | ruolo        | risultato |
      | PA1     | admin        |       200 |
      | PA1     | api          |       403 |
      | PA1     | security     |       403 |
      | PA1     | api,security |       403 |
      | PA1     | support      |       403 |
      | GSP     | admin        |       200 |
      | GSP     | api          |       403 |
      | GSP     | security     |       403 |
      | GSP     | api,security |       403 |
      | GSP     | support      |       403 |
      | Privato | admin        |       200 |
      | Privato | api          |       403 |
      | Privato | security     |       403 |
      | Privato | api,security |       403 |
      | Privato | support      |       403 |

  @purpose_suspend2
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE, alla richiesta di sospensione da parte di un utente con sufficienti permessi dell’ente erogatore, che non coincide con l’ente fruitore, va a buon fine
    Given l'utente è un "admin" di "PA2"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    When l'utente sospende quella finalità in stato "ACTIVE"
    Then si ottiene status code 200

  @purpose_suspend3
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE o SUSPENDED, alla richiesta di sospensione da parte di un utente con sufficienti permessi dell’ente erogatore, che coincide con l’ente fruitore, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente sospende quella finalità in stato "<statoFinalita>"
    Then si ottiene status code 200

    Examples: 
      | statoFinalita |
      | ACTIVE        |
      | SUSPENDED     |

  @purpose_suspend4a @wait_for_fix @IMN-404
  Scenario Outline: Per una finalità precedentemente creata da un fruitore, la quale è in stato WAITING_FOR_APPROVAL, DRAFT o ARCHIVED, alla richiesta di sospensione da parte di un utente con sufficienti permessi, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente sospende quella finalità in stato "<statoFinalita>"
    Then si ottiene status code 403

    Examples: 
      | statoFinalita        |
      | WAITING_FOR_APPROVAL |
      | DRAFT                |
      | ARCHIVED             |

  @purpose_suspend4b @fixed_in_node
  Scenario Outline: Per una finalità precedentemente creata da un fruitore, la quale è in stato REJECTED, alla richiesta di sospensione da parte di un utente con sufficienti permessi, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "WAITING_FOR_APPROVAL" per quell'eservice
    Given "PA2" ha già rifiutato l'aggiornamento della stima di carico per quella finalità
    When l'utente sospende quella finalità in stato "REJECTED"
    Then si ottiene status code 400
