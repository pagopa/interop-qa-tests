@purpose_update_draft_mode_deliver
Feature: Aggiornamento bozza nuova finalità in erogazione diretta

  @purpose_update_draft_mode_deliver1
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato DRAFT per una versione di e-service, il quale ha mode = DELIVER, aggiorna una finalità con tutti i campi richiesti correttamente formattati. La richiesta va a buon fine.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "<ruolo>" di "<ente>" ha già creato 1 finalità in stato "DRAFT" per quell'eservice
    When l'utente aggiorna quella finalità per quell'e-service in erogazione diretta
    Then si ottiene status code 200

    Examples: 
      | ente    | ruolo | risultato |
      | PA1     | admin |       200 |
      | GSP     | admin |       200 |
      | Privato | admin |       200 |

  @purpose_update_draft_mode_deliver2
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato NON DRAFT (ACTIVE, SUSPENDED, WAITING_FOR_APPROVAL o ARCHIVED) per una versione di e-service, il quale ha mode = DELIVER, aggiorna una finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore (NB: verificare status code).
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalità>" per quell'eservice
    When l'utente aggiorna quella finalità per quell'e-service in erogazione diretta
    Then si ottiene status code 400

    Examples: 
      | statoFinalità        |
      | ACTIVE               |
      | SUSPENDED            |
      | WAITING_FOR_APPROVAL |
      | ARCHIVED             |

  @purpose_update_draft_mode_deliver3
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato DRAFT per una versione di e-service, il quale ha mode = DELIVER, aggiorna una finalità con tutti i campi richiesti correttamente formattati, con una riskAnalysis in versione diversa da quella attualmente pubblicata (es. il fruitore ha compilato la v1, la versione attuale è la v2). Ottiene un errore (NB: verificare status code).
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "DRAFT" per quell'eservice
    When l'utente aggiorna quella finalità per quell'e-service in erogazione diretta con una riskAnalysis in versione diversa da quella attualmente pubblicata
    Then si ottiene status code 400
