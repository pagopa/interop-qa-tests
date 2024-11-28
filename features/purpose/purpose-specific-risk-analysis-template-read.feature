@purpose_risk_analysis_read
Feature: Lettura di una specifica versione di analisi del rischio
  Tutti gli utenti possono leggere una specifica versione di analisi del rischio

  @purpose_risk_analysis_read1 @fixed_in_node
  Scenario Outline: Per una richiesta di lettura di una specifica versione di template di analisi del rischio da parte di un ente, alla richiesta di lettura per un e-service di erogazione diretta, ottiene la specifica versione di analisi del rischio dedicata all’ente fruitore
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    When l'utente richiede la versione "2.0" del template dell'analisi del rischio
    Then si ottiene status code 200 e il template in versione "2.0"

    Examples:
      | ente    | ruolo        |
      | PA1     | admin        |
      | PA1     | api          |
      | PA1     | security     |
      | PA1     | api,security |
      | PA1     | support      |
      | GSP     | admin        |
      | GSP     | api          |
      | GSP     | security     |
      | GSP     | api,security |
      | GSP     | support      |
      | Privato | admin        |
      | Privato | api          |
      | Privato | security     |
      | Privato | api,security |
      | Privato | support      |

  @purpose_risk_analysis_read2
  Scenario Outline: Per una richiesta di lettura di una specifica versione di template di analisi del rischio da parte di un ente, alla richiesta di lettura per un e-service di erogazione inversa, ottiene la specifica versione di analisi del rischio dedicata all’ente erogatore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "PUBLISHED"
    When l'utente richiede la versione "2.0" del template dell'analisi del rischio
    Then si ottiene status code 200 e il template in versione "2.0"
