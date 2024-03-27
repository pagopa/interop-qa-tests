@purpose_risk_analysis_read
Feature: Lettura di una specifica versione di analisi del rischio
vuoi il template

NB: verificare con Ruggero la strategia per testare questo endpoint in maniera robusta. Sarebbe importante testare non solo il 200, ma anche l’effettiva versione, in modo da garantire l’erogazione del corretto template legal

  @purpose_risk_analysis_read1
  Scenario Outline: Per una richiesta di lettura di una specifica versione di template di analisi del rischio da parte di un ente PA, alla richiesta di lettura, ottiene la specifica versione di analisi del rischio dedicata alle PA
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede la versione "2.0" del template dell'analisi del rischio
    Then si ottiene status code <risultato> e il template in versione "2.0"

    Examples: 
      | ente    | ruolo        | risultato |
      | PA1     | admin        |       200 |
      | PA1     | api          |       200 |
      | PA1     | security     |       200 |
      | PA1     | api,security |       200 |
      | PA1     | support      |       200 |

  @purpose_risk_analysis_read2
  Scenario Outline: Per una richiesta di lettura di una specifica versione di template di analisi del rischio da parte di un ente GSP o Privato, alla richiesta di lettura,  ottiene la specifica versione di analisi del rischio dedicata ai Privati
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede la versione "2.0" del template dell'analisi del rischio
    Then si ottiene status code <risultato> e il template in versione "2.0"

    Examples: 
      | ente     | ruolo        | risultato |
      | GSP      | admin        |       200 |
      | GSP      | api          |       200 |
      | GSP      | security     |       200 |
      | GSP      | api,security |       200 |
      | GSP      | support      |       200 |
      | Privato  | admin        |       200 |
      | Privato  | api          |       200 |
      | Privato  | security     |       200 |
      | Privato  | api,security |       200 |
      | Privato  | support      |       200 |