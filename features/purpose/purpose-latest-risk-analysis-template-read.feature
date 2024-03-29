@purpose-latest-risk-analysis-template-read
Feature: Lettura del template di analisi del rischio più recente
  Tutti gli utenti possono leggere il template dell'analisi del rischio, specifico per il proprio ente, di una propria finalità

  @purpose-latest-risk-analysis-template-read1 @wait_for_fix @IMN-405
  Scenario Outline: Per una richiesta di lettura del template di analisi del rischio da parte di un ente, alla richiesta di lettura, ottiene l'ultima versione di analisi del rischio dedicata a quel tipo specifico di ente
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede il template dell'analisi del rischio
    Then si ottiene status code <risultato> e il template in versione "<versione>"

    Examples: 
      | ente    | ruolo        | risultato | versione |
      | PA1     | admin        |       200 |      3.0 |
      | PA1     | api          |       200 |      3.0 |
      | PA1     | security     |       200 |      3.0 |
      | PA1     | api,security |       200 |      3.0 |
      | PA1     | support      |       200 |      3.0 |
      | GSP     | admin        |       200 |      2.0 |
      | GSP     | api          |       200 |      2.0 |
      | GSP     | security     |       200 |      2.0 |
      | GSP     | api,security |       200 |      2.0 |
      | GSP     | support      |       200 |      2.0 |
      | Privato | admin        |       200 |      2.0 |
      | Privato | api          |       200 |      2.0 |
      | Privato | security     |       200 |      2.0 |
      | Privato | api,security |       200 |      2.0 |
      | Privato | support      |       200 |      2.0 |
