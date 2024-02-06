@certified_attribute_creation

Feature: Creazione attributo certificato
  Gli enti certificatori possono creare attributi certificati

  @certified_attribute_creation1
  Scenario Outline: Alla richiesta di creazione di un attributo certificato ben formattato per un ente identificato come certificatore e un utente con permessi admin, la richiesta va a buon fine
    Given l'utente è un "admin" di "<enteCertificatore>"
    When l'utente crea un attributo certificato
    Then si ottiene status code <risultato> 

    Examples: 
      | enteCertificatore    | risultato |
      | PA2                  |       200 |

  @certified_attribute_creation2
  Scenario Outline: Alla richiesta di creazione di un attributo certificato ben formattato per un ente non identificato come certificatore, restituisce un errore
    Given l'utente è un "admin" di "<enteNonCertificatore>"
    When l'utente crea un attributo certificato
    Then si ottiene status code <risultato> 

    Examples: 
      | enteNonCertificatore    | risultato |
      | PA1                     |       403 |
