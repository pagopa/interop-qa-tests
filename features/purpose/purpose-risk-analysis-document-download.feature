@purpose_risk_analysis_document_download
Feature: Download documento di analisi del rischio sigillato
  Tutti gli utenti autorizzati possono scaricare il documento di analisi del rischio di una propria finalità

  @purpose_risk_analysis_document_download1 @wait_for_fix @IMN-401
  Scenario Outline: Per una finalità precedentemente creata dal fruitore, la quale è stata in passato almeno per un momento ACTIVE, alla richiesta di lettura del documento di analisi del rischio da parte di un qualsiasi utente dell'ente, va a buon fine. NB: il documento della richiesta di fruizione viene generato all’attivazione di una versione di finalità. Può essere che se si tenta di scaricarlo immediatamente dopo aver attivato una finalità non sia immediatamente disponibile per i tempi connessi alla generazione del PDF.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "<ente>" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    When l'utente scarica il documento di analisi del rischio
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

  @purpose_risk_analysis_document_download2
  Scenario Outline: Per una finalità precedentemente creata dal fruitore, la quale è stata in passato almeno per un momento ACTIVE, la quale ha avuto un aggiornamento della stima di carico la quale versione è stata almeno per un momento ACTIVE, alla richiesta di lettura del documento di analisi del rischio da parte di un qualsiasi utente dell'ente, va a buon fine; il documento deve essere diverso da quello creato per la versione precedente.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given l'utente ha già aggiornato finalità rispettando le stime di carico per quell'e-service
    When l'utente scarica il documento di analisi del rischio
    Then si ottiene status code 200 e un documento diverso
