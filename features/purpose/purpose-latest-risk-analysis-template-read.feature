@purpose-latest-risk-analysis-template-read
Feature: Lettura del template di analisi del rischio più recente

  @purpose-latest-risk-analysis-template-read1a
  Scenario Outline: Per una richiesta di lettura del template di analisi del rischio da parte di un ente PA, alla richiesta di lettura, ottiene l'ultima versione di analisi del rischio dedicata alle PA
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede il template dell'analisi del rischio
    Then si ottiene status code <risultato> e il template in versione "3.0"

    Examples: 
      | ente    | ruolo        | risultato |
      | PA1     | admin        |       200 |
      | PA1     | support      |       200 |

  @purpose-latest-risk-analysis-template-read1b
  #Non si può ottenere il template se non va a buon fine
  Scenario Outline: Per una richiesta di lettura del template di analisi del rischio da parte di un ente PA, alla richiesta di lettura, ottiene l'ultima versione di analisi del rischio dedicata alle PA
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede il template dell'analisi del rischio
    Then si ottiene status code <risultato>

    Examples: 
      | ente    | ruolo        | risultato |
      | PA1     | api          |       403 |
      | PA1     | security     |       403 |
      | PA1     | api,security |       403 |
     

  @purpose-latest-risk-analysis-template-read2a
  Scenario Outline: Per una richiesta di lettura del template di analisi del rischio da parte di un ente GSP o Privato, alla richiesta di lettura, ottiene l'ultima versione di analisi del rischio dedicata ai Privati
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede il template dell'analisi del rischio
    Then si ottiene status code <risultato> e il template in versione "2.0"

    Examples: 
      | ente     | ruolo        | risultato |
      | GSP      | admin        |       200 |
      | GSP      | support      |       200 |
      | Privato  | admin        |       200 |
      | Privato  | support      |       200 |

  @purpose-latest-risk-analysis-template-read2b
  Scenario Outline: Per una richiesta di lettura del template di analisi del rischio da parte di un ente GSP o Privato, alla richiesta di lettura, ottiene l'ultima versione di analisi del rischio dedicata ai Privati
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede il template dell'analisi del rischio
    Then si ottiene status code <risultato> 

    Examples: 
      | ente     | ruolo        | risultato |
      | GSP      | api          |       403 |
      | GSP      | security     |       403 |
      | GSP      | api,security |       403 |
      | Privato  | api          |       403 |
      | Privato  | security     |       403 |
      | Privato  | api,security |       403 |

