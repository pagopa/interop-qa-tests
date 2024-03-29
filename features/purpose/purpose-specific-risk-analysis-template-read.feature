@purpose_risk_analysis_read
Feature: Lettura di una specifica versione di analisi del rischio
  Tutti gli admin possono leggere una specifica versione di analisi del rischio di una propria finalità

  @purpose_risk_analysis_read1a
  Scenario Outline: Per una richiesta di lettura di una specifica versione di template di analisi del rischio da parte di un ente PA, alla richiesta di lettura, ottiene la specifica versione di analisi del rischio dedicata alle PA
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    When l'utente richiede la versione "2.0" del template dell'analisi del rischio
    Then si ottiene status code 200 e il template in versione "2.0"

  @purpose_risk_analysis_read1b @wait_for_fix @IMN-405
  Scenario Outline: Per una richiesta di lettura di una specifica versione di template di analisi del rischio da parte di un ente PA, alla richiesta di lettura, ottiene la specifica versione di analisi del rischio dedicata alle PA
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato e pubblicato 1 e-service
    When l'utente richiede la versione "2.0" del template dell'analisi del rischio
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | risultato |
      | PA1  | api          |       403 |
      | PA1  | security     |       403 |
      | PA1  | api,security |       403 |
      | PA1  | support      |       403 |

  @purpose_risk_analysis_read2a
  Scenario Outline: Per una richiesta di lettura di una specifica versione di template di analisi del rischio da parte di un ente GSP o Privato, alla richiesta di lettura,  ottiene la specifica versione di analisi del rischio dedicata ai Privati
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    When l'utente richiede la versione "2.0" del template dell'analisi del rischio
    Then si ottiene status code <risultato> e il template in versione "2.0"

    Examples: 
      | ente    | ruolo | risultato |
      | GSP     | admin |       200 |
      | Privato | admin |       200 |

  @purpose_risk_analysis_read2b @wait_for_fix @IMN-405
  Scenario Outline: Per una richiesta di lettura di una specifica versione di template di analisi del rischio da parte di un ente GSP o Privato, alla richiesta di lettura,  ottiene la specifica versione di analisi del rischio dedicata ai Privati
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA1" ha già creato e pubblicato 1 e-service
    When l'utente richiede la versione "2.0" del template dell'analisi del rischio
    Then si ottiene status code <risultato>

    Examples: 
      | ente    | ruolo        | risultato |
      | GSP     | api          |       403 |
      | GSP     | security     |       403 |
      | GSP     | api,security |       403 |
      | GSP     | support      |       403 |
      | Privato | api          |       403 |
      | Privato | security     |       403 |
      | Privato | api,security |       403 |
      | Privato | support      |       403 |
