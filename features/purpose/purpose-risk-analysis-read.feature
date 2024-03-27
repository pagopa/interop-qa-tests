@purpose_risk_analysis_read
Feature: Lettura di una specifica versione di analisi del rischio
NB: verificare con Ruggero la strategia per testare questo endpoint in maniera robusta. Sarebbe importante testare non solo il 200, ma anche l’effettiva versione, in modo da garantire l’erogazione del corretto template legal

  @purpose_risk_analysis_read1
  Scenario Outline: Per una richiesta di lettura di una specifica versione di template di analisi del rischio da parte di un ente PA, alla richiesta di lettura, ottiene l'ultima versione di analisi del rischio dedicata alle PA

  @purpose_risk_analysis_read2
  Scenario Outline: Per una richiesta di lettura di una specifica versione di template di analisi del rischio da parte di un ente GSP o Privato, alla richiesta di lettura, ottiene l'ultima versione di analisi del rischio dedicata ai Privati