@purpose_update_draft_mode_receive
Feature: Aggiornamento bozza nuova finalità in erogazione inversa
  Tutti gli utenti admin possono aggiornare una finalità in bozza per un e-service in erogazione inversa.

  @purpose_update_draft_mode_receive1
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato DRAFT per una versione di e-service, il quale ha mode = RECEIVE, aggiorna una finalità con tutti i campi richiesti correttamente formattati. La richiesta va a buon fine.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA1" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given "PA1" ha già creato un'analisi del rischio per quell'e-service
    Given "PA1" ha già caricato un'interfaccia per quel descrittore
    Given "PA1" ha già pubblicato quella versione di e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "<ente>" ha già creato una finalità in stato "DRAFT" per quell'eservice associando quell'analisi del rischio creata dall'erogatore
    When l'utente aggiorna quella finalità per quell'e-service in erogazione inversa
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

  @purpose_update_draft_mode_receive2
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato NON DRAFT (ACTIVE, SUSPENDED, WAITING_FOR_APPROVAL o ARCHIVED) per una versione di e-service, il quale ha mode = RECEIVE, aggiorna una finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given "PA2" ha già creato un'analisi del rischio per quell'e-service
    Given "PA2" ha già caricato un'interfaccia per quel descrittore
    Given "PA2" ha già pubblicato quella versione di e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato una finalità in stato "<statoFinalità>" per quell'eservice associando quell'analisi del rischio creata dall'erogatore
    When l'utente aggiorna quella finalità per quell'e-service in erogazione inversa
    Then si ottiene status code 403

    Examples: 
      | statoFinalità        |
      | ACTIVE               |
      | SUSPENDED            |
      | WAITING_FOR_APPROVAL |
      | ARCHIVED             |
