@purpose_version_create
Feature: Creazione di una nuova versione di finalità
  Tutti gli utenti admin di un ente fruitore possono richiedere un cambio di piano aggiornando le dailyCalls

  @purpose_version_create1a
  Scenario Outline: Un utente con sufficienti permessi; il cui ente ha già una finalità in stato ACTIVE o SUSPENDED e non ha versioni in stato WAITING_FOR_APPROVAL per una versione di e-service, aggiorna la stima di carico di una finalità. La richiesta va a buon fine e la finalità viene aggiornata con la nuova stima di carico restando dello stato originale.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "<ente>" ha già creato 1 finalità in stato "<statoFinalità>" per quell'eservice
    When l'utente aggiorna la stima di carico per quella finalità
    Then si ottiene status code 200 e la nuova versione della finalità è stata creata in stato "<statoFinalità>" con la nuova stima di carico

    Examples: # Test sui ruoli
      | ente    | ruolo | statoFinalità |
      | PA1     | admin | ACTIVE        |
      | GSP     | admin | ACTIVE        |
      | Privato | admin | ACTIVE        |

    Examples: # Test sui stati finalità
      | ente | ruolo | statoFinalità |
      | PA1  | admin | SUSPENDED     |

  @purpose_version_create1b
  Scenario Outline: Un utente senza sufficienti permessi; il cui ente ha già una finalità in stato ACTIVE o SUSPENDED e non ha versioni in stato WAITING_FOR_APPROVAL per una versione di e-service, aggiorna la stima di carico di una finalità. Ottiene un errore.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "<ente>" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    When l'utente aggiorna la stima di carico per quella finalità
    Then si ottiene status code 403

    Examples: # Test sui ruoli
      | ente    | ruolo        |
      | PA1     | api          |
      | PA1     | security     |
      | PA1     | api,security |
      | PA1     | support      |
      | GSP     | api          |
      | GSP     | security     |
      | GSP     | api,security |
      | GSP     | support      |
      | Privato | api          |
      | Privato | security     |
      | Privato | api,security |
      | Privato | support      |

  @purpose_version_create2
  Scenario Outline: Un utente con sufficienti permessi; il cui ente ha già una finalità in stato ACTIVE o SUSPENDED e ha già una versione successiva in stato WAITING_FOR_APPROVAL per una versione di e-service, aggiorna la stima di carico di una finalità. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    Given l'utente crea una versione nuova della finalità in stato WAITING_FOR_APPROVAL
    When l'utente aggiorna la stima di carico per quella finalità
    Then si ottiene status code 409

    Examples:
      | statoFinalita |
      | ACTIVE        |
      | SUSPENDED     |

  @purpose_version_create3 @wait_for_fix @IMN-400
  Scenario Outline: Un utente con sufficienti permessi; il cui ente ha già una finalità in stato DRAFT, WAITING_FOR_APPROVAL o ARCHIVED per una versione di e-service, aggiorna la stima di carico di una finalità. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente aggiorna la stima di carico per quella finalità
    Then si ottiene status code 409

    Examples:
      | statoFinalita        |
      | DRAFT                |
      | WAITING_FOR_APPROVAL |
      | ARCHIVED             |

  @purpose_version_create4
  Scenario Outline: Un utente con sufficienti permessi; il cui ente ha già una finalità in stato ACTIVE e non ha versioni in stato WAITING_FOR_APPROVAL per una versione di e-service, aggiorna la stima di carico di una finalità superando la quota massima. La richiesta va a buon fine e la finalità viene aggiornata con la nuova stima di carico andando in WAITING_FOR_APPROVAL.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    When l'utente aggiorna la stima di carico per quella finalità
    Then si ottiene status code 200 e la nuova versione della finalità è stata creata in stato "WAITING_FOR_APPROVAL" con la nuova stima di carico
