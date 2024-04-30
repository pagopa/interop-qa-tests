@purpose_risk_analysis_read
Feature: Lettura di una specifica versione di analisi del rischio
  Tutti gli utenti possono leggere una specifica versione di analisi del rischio

  @purpose_risk_analysis_read1 @wait_for_fix @PIN-4772
  Scenario Outline: Per una richiesta di lettura di una specifica versione di template di analisi del rischio da parte di un ente, alla richiesta di lettura per un e-service di erogazione diretta, ottiene la specifica versione di analisi del rischio dedicata all’ente fruitore
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    When l'utente richiede la versione "2.0" del template dell'analisi del rischio
    Then si ottiene status code 200 e il template in versione "2.0"

    Examples: 
      | ente    | ruolo        | risultato |
      | PA1     | admin        |       200 |
      | PA1     | api          |       200 |
      | PA1     | security     |       200 |
      | PA1     | api,security |       200 |
      | PA1     | support      |       200 |
      | GSP     | admin        |       200 |
      | GSP     | api          |       200 |
      | GSP     | security     |       200 |
      | GSP     | api,security |       200 |
      | GSP     | support      |       200 |
      | Privato | admin        |       200 |
      | Privato | api          |       200 |
      | Privato | security     |       200 |
      | Privato | api,security |       200 |
      | Privato | support      |       200 |

  @purpose_risk_analysis_read2
  Scenario Outline: Per una richiesta di lettura di una specifica versione di template di analisi del rischio da parte di un ente, alla richiesta di lettura per un e-service di erogazione inversa, ottiene la specifica versione di analisi del rischio dedicata all’ente erogatore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "PUBLISHED"
    When l'utente richiede la versione "2.0" del template dell'analisi del rischio
    Then si ottiene status code 200 e il template in versione "2.0"

