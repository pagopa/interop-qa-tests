@purpose-latest-risk-analysis-template-read
Feature: Lettura del template di analisi del rischio più recente

  @purpose-latest-risk-analysis-template-read1
  Scenario Outline: Per una richiesta di lettura del template di analisi del rischio da parte di un ente PA, alla richiesta di lettura, ottiene l'ultima versione di analisi del rischio dedicata alle PA
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede il template dell'analisi del rischio
    Then si ottiene status code <risultato> e la versione ottenuta è la "3.0"

    Examples: 
      | ente    | ruolo        | risultato |
      | PA1     | admin        |       200 |
      | PA1     | api          |       200 |
      | PA1     | security     |       200 |
      | PA1     | api,security |       200 |
      | PA1     | support      |       200 |
     

  @purpose-latest-risk-analysis-template-read2
  Scenario Outline: Per una richiesta di lettura del template di analisi del rischio da parte di un ente GSP o Privato, alla richiesta di lettura, ottiene l'ultima versione di analisi del rischio dedicata ai Privati
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede il template dell'analisi del rischio
    Then si ottiene status code <risultato> e la versione ottenuta è la "2.0"

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

