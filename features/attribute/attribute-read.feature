@attribute_read
Feature: Lettura singolo attributo
  Tutti gli utenti autenticati possono leggere le informazioni di un singolo attributo

  @attribute_read1
  Scenario Outline: Alla richiesta di un attributo presente in DB, restituisce il risultato
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA1" ha già creato 1 attributo "DECLARED"
    When l'utente richiede una operazione di lettura di quel attributo
    Then si ottiene status code 200

    Examples: 
      | ente    | ruolo        |
      | GSP     | admin        |
      | GSP     | api          |
      | GSP     | security     |
      | GSP     | support      |
      | GSP     | api,security |
      | PA1     | admin        |
      | PA1     | api          |
      | PA1     | security     |
      | PA1     | support      |
      | PA1     | api,security |
      | Privato | admin        |
      | Privato | api          |
      | Privato | security     |
      | Privato | support      |
      | Privato | api,security |
