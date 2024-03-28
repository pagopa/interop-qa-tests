@purpose-read
Feature: Lettura singola finalità
  Tutti gli utenti autorizzati possono leggere una finalità.

  @purpose-read1
  Scenario Outline: Per una finalità precedentemente creata dal fruitore, la quale prima versione è in qualsiasi stato (DRAFT, WAITING_FOR_APPROVAL, ACTIVE, SUSPENDED, ARCHIVED), alla richiesta di lettura, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "<ente>" ha già creato 1 finalità in stato "<statoFinalità>" per quell'eservice
    When l'utente richiede la lettura della finalità
    Then si ottiene status code <risultato>

    Examples: # Test sui ruoli
      | ente | ruolo        | statoFinalità | risultato |
      | PA1  | admin        | ACTIVE        |       200 |
      | PA1  | api          | ACTIVE        |       403 |
      | PA1  | security     | ACTIVE        |       200 |
      | PA1  | api,security | ACTIVE        |       200 |
      | PA1  | support      | ACTIVE        |       200 |
      | GSP  | admin        | ACTIVE        |       200 |
      | GSP  | api          | ACTIVE        |       403 |
      | GSP  | security     | ACTIVE        |       200 |
      | GSP  | api,security | ACTIVE        |       200 |
      | GSP  | support      | ACTIVE        |       200 |

    Examples: # Test sugli stati
      | ente | ruolo | statoFinalità        | risultato |
      | PA1  | admin | WAITING_FOR_APPROVAL |       200 |
      | PA1  | admin | SUSPENDED            |       200 |
      | PA1  | admin | ARCHIVED             |       200 |
      | PA1  | admin | DRAFT                |       200 |

  @purpose-read2
  Scenario Outline: Per una finalità precedentemente creata da un fruitore, la quale prima versione è in stato NON DRAFT (WAITING_FOR_APPROVAL, ACTIVE, SUSPENDED, ARCHIVED), alla richiesta di lettura da parte dell’erogatore, va a buon fine
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente richiede la lettura della finalità
    Then si ottiene status code 200

    Examples: 
      | statoFinalita        |
      | ACTIVE               |
      | SUSPENDED            |
      | WAITING_FOR_APPROVAL |
      | ARCHIVED             |

  @purpose-read3 @resource_intensive
  Scenario Outline: Per una finalità precedentemente creata da un fruitore, la quale prima versione è in qualsiasi stato (DRAFT, (WAITING_FOR_APPROVAL, ACTIVE, SUSPENDED, ARCHIVED), alla richiesta di lettura da parte di un ente che non è né l'erogatore, né il fruitore, va a buon fine ma non ottiene l'analisi del rischio
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente richiede la lettura della finalità
    Then si ottiene status code 200 ma non l'analisi del rischio

    Examples: 
      | statoFinalita        |
      | DRAFT                |
      | ACTIVE               |
      | SUSPENDED            |
      | WAITING_FOR_APPROVAL |
      | ARCHIVED             |
