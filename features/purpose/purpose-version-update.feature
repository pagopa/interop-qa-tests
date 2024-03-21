@purpose_update
Feature: Creazione di una nuova versione di finalità

  @purpose_update1a
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato ACTIVE o SUSPENDED e non ha versioni in stato WAITING_FOR_APPROVAL per una versione di e-service, aggiorna la stima di carico di una finalità. La richiesta va a buon fine.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "ente" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given l'utente non ha finalità in stato WAITING_FOR_APPROVAL
    Given un "<ruolo>" di "<ente>" ha già creato 1 finalità in stato "ACTIVE" per quell'e-service
    When l'utente aggiorna la stima di carico per quella finalità
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

  @purpose_update1b
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato SUSPENDED e non ha versioni in stato WAITING_FOR_APPROVAL per una versione di e-service, aggiorna la stima di carico di una finalità. La richiesta va a buon fine.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given l'utente non ha finalità in stato WAITING_FOR_APPROVAL
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "SUSPENDED" per quell'e-service
    When l'utente aggiorna la stima di carico per quella finalità
    Then si ottiene status code 200

  @purpose_update2
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato ACTIVE o SUSPENDED e ha già una versione successiva in stato WAITING_FOR_APPROVAL per una versione di e-service, aggiorna la stima di carico di una finalità. Ottiene un errore (NB: verificare status code). Spiega: non è possibile avere diverse version in WAITING_FOR_APPROVAL sulla stessa finalità, solo una per volta
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'e-service
    Given l'utente  ha già una finalità in stato WAITING_FOR_APPROVAL
    When l'utente aggiorna la stima di carico per quella finalità
    Then si ottiene status code 400

    Examples: 
      | statoFinalita |
      | ACTIVE        |
      | SUSPENDED     |

  @purpose_update3
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato DRAFT, WAITING_FOR_APPROVAL o ARCHIVED per una versione di e-service, aggiorna la stima di carico di una finalità. Ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'e-service
    When l'utente aggiorna la stima di carico per quella finalità
    Then si ottiene status code 400

    Examples: 
      | statoFinalita        |
      | DRAFT                |
      | WAITING_FOR_APPROVAL |
      | ARCHIVED             |
