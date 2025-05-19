@certified_attribute_creation
Feature: Creazione attributo certificato
  Gli enti certificatori possono creare attributi certificati

  @certified_attribute_creation1
  Scenario Outline: Un utente admin di un ente certificatore può creare un attributo certificato
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente crea un attributo certificato
    Then si ottiene status code <risultato>

    Examples: #PA1 e Privato non sono enti certificatori
      | ente    | ruolo        | risultato |
      | PA1     | admin        |       200 |
      | PA1     | api          |       403 |
      | PA1     | security     |       403 |
      | PA1     | api,security |       403 |
      | PA1     | support      |       403 |
      | PA2     | admin        |       200 |
      | PA2     | api          |       403 |
      | PA2     | security     |       403 |
      | PA2     | api,security |       403 |
      | PA2     | support      |       403 |
      | Privato | admin        |       403 |
      | Privato | api          |       403 |
      | Privato | security     |       403 |
      | Privato | api,security |       403 |
      | Privato | support      |       403 |
