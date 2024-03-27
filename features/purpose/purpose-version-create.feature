@purpose_version_create
Feature: Creazione di una nuova versione di finalità

  @purpose_version_create1
  Scenario Outline: Un utente con sufficienti permessi; il cui ente ha già una finalità in stato ACTIVE o SUSPENDED e non ha versioni in stato WAITING_FOR_APPROVAL per una versione di e-service, aggiorna la stima di carico di una finalità. La richiesta va a buon fine.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "<ente>" ha già creato 1 finalità in stato "<statoFinalità>" per quell'eservice
    When l'utente aggiorna la stima di carico per quella finalità
    Then si ottiene status code <risultato>

    Examples: # Test sui ruoli
      | ente    | ruolo        | statoFinalità | risultato |
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
      | ente | ruolo | statoFinalità | risultato |
      | PA1  | admin | SUSPENDED     |       200 |

  @purpose_version_create2
  Scenario Outline: Un utente con sufficienti permessi; il cui ente ha già una finalità in stato ACTIVE o SUSPENDED e ha già una versione successiva in stato WAITING_FOR_APPROVAL per una versione di e-service, aggiorna la stima di carico di una finalità. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    Given l'utente crea una versione nuova della finalità in stato WAITING_FOR_APPROVAL
    When l'utente aggiorna la stima di carico per quella finalità
    Then si ottiene status code 409

    Examples: 
      | statoFinalita |
      | ACTIVE        |
      | SUSPENDED     |
      
  # Attualmente è possibile creare una nuova versione della finalità anche se è in stato ARCHIVED
  @purpose_version_create3 @wait_for_fix
  Scenario Outline: Un utente con sufficienti permessi; il cui ente ha già una finalità in stato DRAFT, WAITING_FOR_APPROVAL o ARCHIVED per una versione di e-service, aggiorna la stima di carico di una finalità. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente aggiorna la stima di carico per quella finalità
    Then si ottiene status code 409

    Examples: 
      | statoFinalita        |
      | DRAFT                |
      | WAITING_FOR_APPROVAL |
      | ARCHIVED             |
