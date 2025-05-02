@tenant_requester_certified_attributes_listing
Feature: Listing attributi certificati assegnati dall'ente certificatore
  Tutti gli utenti autorizzati di enti certificatori possono leggere la lista degli attributi certificati assegnati.
  Ai fini dei test solo PA2 e GSP2 sono certificatori, la quale qualifica non può essere assegnata durante la loro esecuzione.

  @tenant_requester_certified_attributes_listing1 @to_fix # Invalid roles for this operation
  Scenario Outline: A fronte di una richiesta di listing di attributi certificati, la richiesta va buon fine solo se il richiedente è un ente certificatore
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede una operazione di listing senza paginazione degli attributi certificati assegnati
    Then si ottiene status code <statusCode>

    Examples: # PA2 è certificatore
      | ente    | ruolo        | statusCode |
      | PA1     | admin        |        200 |
      | PA1     | api          |        403 |
      | PA1     | security     |        403 |
      | PA1     | support      |        200 |
      | PA1     | api,security |        403 |
      | PA2     | admin        |        200 |
      | PA2     | api          |        403 |
      | PA2     | security     |        403 |
      | PA2     | support      |        200 |
      | PA2     | api,security |        403 |
      | Privato | admin        |        403 |
      | Privato | api          |        403 |
      | Privato | security     |        403 |
      | Privato | support      |        403 |
      | Privato | api,security |        403 |
      | GSP     | admin        |        200 |
      | GSP     | api          |        403 |
      | GSP     | security     |        403 |
      | GSP     | support      |        200 |
      | GSP     | api,security |        403 |

  @tenant_requester_certified_attributes_listing2
  Scenario Outline: A fronte di una richiesta di listing di attributi certificati creati e assegnati dall'ente richiedente, va a buon fine e l'attributo creato è contenuto nei risultati
    Given l'utente è un "admin" di "PA2"
    Given "PA2" ha creato un attributo certificato e lo ha assegnato a "PA1"
    When l'utente richiede una operazione di listing degli attributi certificati assegnati
    Then si ottiene status code 200 e la lista degli attributi contenente l'attributo assegnato a "PA1"
