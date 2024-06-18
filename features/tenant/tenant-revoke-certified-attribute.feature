@tenant-revoke-certified-attribute
Feature: Revoca di un attributo certificato posseduto da uno specifico aderente
  Tutti gli utenti autenticati degli enti certificatori possono revocare uno degli attributi certificati che hanno assegnato precedentemente

  @tenant-revoke-certified-attribute1
  Scenario Outline: Per un attributo precedentemente certificato da un aderente, il quale ha la qualifica di ente certificatore (certifier), ad un altro ente, alla richiesta di revoca da parte di un utente con sufficienti permessi (admin), va a buon fine
    Given l'utente è un "<ruolo>" di "PA2"
    Given "PA2" ha creato un attributo certificato e lo ha assegnato a "PA1"
    When l'utente revoca l'attributo precedentemente creato e assegnato
    Then si ottiene status code <statusCode>

    Examples:
      | ruolo        | statusCode |
      | admin        |        200 |
      | api          |        400 |
      | security     |        400 |
      | support      |        400 |
      | api,security |        400 |

  @tenant-revoke-certified-attribute2a
  Scenario Outline: Per un attributo precedentemente certificato da un primo aderente, il quale ha la qualifica di ente certificatore (certifier), ad un secondo ente, alla richiesta di revoca da parte di un utente con sufficienti permessi (admin) appartenente ad un terzo ente certificatore, ottiene un errore
    Given l'utente è un "admin" di "<ente>"
    Given "PA2" ha creato un attributo certificato e lo ha assegnato a "GSP"
    When l'utente revoca l'attributo precedentemente creato e assegnato
    Then si ottiene status code 400
    #PA3 andrà in errore perchè è un certificatore diverso da chi ha assegnato l'attributo
    #PA1 andrà in errore perchè non è un certificatore

    Examples:
      | ente |
      | PA3  |
      | PA1  |
