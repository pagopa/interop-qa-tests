@tenant-read
Feature: Lettura di un singolo aderente
  Tutti gli utenti autenticati possono leggere un singolo aderente

  @tenant-read1
  Scenario Outline: Per un aderente della piattaforma, alla richiesta di lettura da parte di qualsiasi livello di permesso associato a qualsiasi tipologia di ente, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede la lettura dell'aderente "PA2"
    Then si ottiene status code 200 

# To do vedere se è più coerente fare la query su un tenantId terzo, oppure sul proprio ente
    Examples:
      | ente    | ruolo        |
      | GSP     | admin        |
      | GSP     | api          |
      | GSP     | security     |
      | GSP     | api,security |
      | GSP     | support      |
      | PA1     | api          |
      | PA1     | admin        |
      | PA1     | security     |
      | PA1     | support      |
      | PA1     | api,security |
      | Privato | admin        |
      | Privato | api          |
      | Privato | security     |
      | Privato | support      |
      | Privato | api,security |
