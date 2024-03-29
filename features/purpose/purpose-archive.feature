@purpose_archive
Feature: Archiviazione di una finalità
  Tutti gli utenti admin possono archiviare una propria finalità

  @purpose_archive1
  Scenario Outline: Per una finalità precedentemente creata da un fruitore, la quale è in stato ACTIVE o SUSPENDED, alla richiesta di archiviazione da parte di un utente con sufficienti permessi dell’ente fruitore, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "<ente>" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    When l'utente archivia quella finalità in stato "ACTIVE"
    Then si ottiene status code <risultato>

    Examples: # Test sui ruoli
      | ente    | ruolo        | statoFinalita | risultato |
      | PA1     | admin        | ACTIVE        |       200 |
      | PA1     | api          | ACTIVE        |       403 |
      | PA1     | security     | ACTIVE        |       403 |
      | PA1     | api,security | ACTIVE        |       403 |
      | PA1     | support      | ACTIVE        |       403 |
      | GSP     | admin        | ACTIVE        |       200 |
      | GSP     | api          | ACTIVE        |       403 |
      | GSP     | security     | ACTIVE        |       403 |
      | GSP     | api,security | ACTIVE        |       403 |
      | GSP     | support      | ACTIVE        |       403 |
      | Privato | admin        | ACTIVE        |       200 |
      | Privato | api          | ACTIVE        |       403 |
      | Privato | security     | ACTIVE        |       403 |
      | Privato | api,security | ACTIVE        |       403 |
      | Privato | support      | ACTIVE        |       403 |

    Examples: # Test sugli stati
      | ente | ruolo | statoFinalita | risultato |
      | PA1  | admin | SUSPENDED     |       200 |

  @purpose_archive2 @wait_for_fix @IMN-402
  Scenario Outline: Per una finalità precedentemente creata da un fruitore, la quale è in stato ACTIVE o SUSPENDED, con una versione di finalità successiva in stato WAITING_FOR_APPROVAL alla richiesta di archiviazione da parte di un utente con sufficienti permessi dell’ente fruitore, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    When l'utente archivia quella finalità in stato "WAITING_FOR_APPROVAL"
    Then si ottiene status code 200

    Examples: 
      | statoFinalita |
      | ACTIVE        |
      | SUSPENDED     |

  @purpose_archive3
  Scenario Outline: Per una finalità precedentemente creata da un fruitore, la quale è in stato ACTIVE o SUSPENDED, alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA2" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente archivia quella finalità in stato "<statoFinalita>"
    Then si ottiene status code 403

    Examples: 
      | statoFinalita |
      | ACTIVE        |
      | SUSPENDED     |

  @purpose_archive4a @wait_for_fix @IMN-402
  Scenario Outline: Per una finalità precedentemente creata da un fruitore, la quale è in stato REJECTED, WAITING_FOR_APPROVAL, DRAFT o ARCHIVED, alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente archivia quella finalità in stato "<statoFinalita>"
    Then si ottiene status code 403

    Examples: 
      | statoFinalita        |
      | WAITING_FOR_APPROVAL |
      | DRAFT                |
      | ARCHIVED             |

  @purpose_archive4b @wait_for_fix
  Scenario Outline: Per una finalità precedentemente creata da un fruitore, la quale è in stato REJECTED, WAITING_FOR_APPROVAL, DRAFT o ARCHIVED, alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "WAITING_FOR_APPROVAL" per quell'eservice
    Given "PA2" ha già rifiutato l'aggiornamento della stima di carico per quella finalità
    When l'utente archivia quella finalità in stato "REJECTED"
    Then si ottiene status code 403
