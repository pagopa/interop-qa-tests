@certified_attribute_creation

Feature: Creazione attributo certificato
  Gli enti certificatori possono creare attributi certificati

  @certified_attribute_creation1 @wait_for_fix
  Scenario Outline: Un utente admin di un ente certificatore crea un attributo certificato
    Given l'utente è un "<ruolo>" di "<enteCertificatore>"
    When l'utente crea un attributo certificato
    Then si ottiene status code <risultato> 

    Examples: 
      | enteCertificatore    | ruolo        | risultato |
      | PA2                  | admin        |       200 |
      | PA2                  | api          |       403 |
      | PA2                  | security     |       403 |
      | PA2                  | api,security |       403 |
      | PA2                  | support      |       403 |

  @certified_attribute_creation2
  Scenario Outline: Un utente di un ente non certificatore non può creare un attributo certificato
    Given l'utente è un "<ruolo>" di "<enteNonCertificatore>"
    When l'utente crea un attributo certificato
    Then si ottiene status code <risultato> 

    Examples: 
      | enteNonCertificatore    | ruolo        | risultato |
      | PA1                     | admin        |       403 |
      | PA1                     | api          |       403 |
      | PA1                     | security     |       403 |
      | PA1                     | api,security |       403 |
      | PA1                     | support      |       403 |
