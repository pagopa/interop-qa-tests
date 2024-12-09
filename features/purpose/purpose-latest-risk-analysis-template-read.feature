@purpose_latest_risk_analysis_template_read
Feature: Lettura del template di analisi del rischio più recente
  Tutti gli utenti possono leggere il template dell'analisi del rischio, specifico per il proprio ente, di una propria finalità

  @purpose_latest_risk_analysis_template_read1 @fixed_in_node
  Scenario Outline: Per una richiesta di lettura del template di analisi del rischio da parte di un ente, alla richiesta di lettura, ottiene l'ultima versione di analisi del rischio dedicata a quel tipo specifico di ente
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede il template dell'analisi del rischio
    Then si ottiene status code 200 e il template in versione "<versione>"

    Examples:
      | ente    | ruolo        | versione |
      | PA1     | admin        |      3.0 |
      | PA1     | api          |      3.0 |
      | PA1     | security     |      3.0 |
      | PA1     | api,security |      3.0 |
      | PA1     | support      |      3.0 |
      | GSP     | admin        |      2.0 |
      | GSP     | api          |      2.0 |
      | GSP     | security     |      2.0 |
      | GSP     | api,security |      2.0 |
      | GSP     | support      |      2.0 |
      | Privato | admin        |      2.0 |
      | Privato | api          |      2.0 |
      | Privato | security     |      2.0 |
      | Privato | api,security |      2.0 |
      | Privato | support      |      2.0 |
