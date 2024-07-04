@tenant_requester_certified_attributes_listing
Feature: Listing attributi certificati assegnati dall'ente certificatore
  Tutti gli utenti certificatori possono leggere la lista degli attributi certificati assegnati 

  @tenant_requester_certified_attributes_listing1
  Scenario Outline: A fronte di una richiesta di listing di attributi certificati creati e assegnati dall'ente richiedente, la richiesta va buon fine solo se il richiedente è un ente certificatore
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede una operazione di listing degli attributi certificati assegnati
    Then si ottiene status code <statusCode>

    Examples:
      | ente    | ruolo        | statusCode |
      | PA1     | admin        |        403 |
      | PA1     | api          |        403 |
      | PA1     | security     |        403 |
      | PA1     | support      |        403 |
      | PA1     | api,security |        403 |
      | PA2     | admin        |        200 |
      | PA2     | api          |        200 |
      | PA2     | security     |        200 |
      | PA2     | support      |        200 |
      | PA2     | api,security |        200 |
      | Privato | admin        |        403 |
      | Privato | api          |        403 |
      | Privato | security     |        403 |
      | Privato | support      |        403 |
      | Privato | api,security |        403 |

  @tenant_requester_certified_attributes_listing2
  Scenario Outline: A fronte di una richiesta di listing di attributi certificati creati e assegnati dall'ente richiedente, va a buon fine
  # ci restituisce l'errore "The server was not able to produce a timely response to your request. Please try again in a short while!"
    Given l'utente è un "admin" di "PA2"
    Given "PA2" ha creato un attributo certificato e lo ha assegnato a "PA1"
    When l'utente richiede una operazione di listing degli attributi certificati assegnati
    Then si ottiene status code 200 e la lista degli attributi contenente l'attributo assegnato a "PA1"
