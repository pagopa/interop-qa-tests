@purpose_delete
Feature: Cancellazione finalità
  Tutti gli admin possono cancellare una propria finalità in stato DRAFT o WAITING_FOR_APPROVAL.

  @purpose_delete1
  Scenario Outline: Per una finalità precedentemente creata dall’ente, la quale prima versione è in stato DRAFT, alla richiesta di cancellazione da parte di un utente con sufficienti permessi (admin), va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "<ente>" ha già creato 1 finalità in stato "DRAFT" per quell'eservice
    When l'utente richiede la cancellazione della finalità
    Then si ottiene status code <risultato>

    Examples: 
      | ente    | ruolo        | risultato |
      | PA1     | admin        |       204 |
      | PA1     | api          |       403 |
      | PA1     | security     |       403 |
      | PA1     | api,security |       403 |
      | PA1     | support      |       403 |
      | GSP     | admin        |       204 |
      | GSP     | api          |       403 |
      | GSP     | security     |       403 |
      | GSP     | api,security |       403 |
      | GSP     | support      |       403 |
      | Privato | admin        |       204 |
      | Privato | api          |       403 |
      | Privato | security     |       403 |
      | Privato | api,security |       403 |
      | Privato | support      |       403 |

  @purpose_delete2
  Scenario Outline: Per una finalità precedentemente creata dall’ente, la quale prima versione è in stato ACTIVE, SUSPENDED, WAITING_FOR_APPROVAL o ARCHIVED, alla richiesta di cancellazione da parte di un utente con sufficienti permessi (admin), ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente richiede la cancellazione della finalità
    Then si ottiene status code <risultato>

    Examples: 
      | statoFinalita        | risultato |
      | ACTIVE               |       409 |
      | SUSPENDED            |       409 |
      | WAITING_FOR_APPROVAL |       204 |
      | ARCHIVED             |       409 |

  @purpose_delete3
  Scenario Outline: Per una finalità precedentemente creata dall’ente, la quale prima versione è in stato DRAFT, alla richiesta di cancellazione da parte di un utente con sufficienti permessi (admin), che non è nè l'erogatore nè il fruitore, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già creato 1 finalità in stato "DRAFT" per quell'eservice
    When l'utente richiede la cancellazione della finalità
    Then si ottiene status code 403