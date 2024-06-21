@tenant-revoke-certified-attribute
Feature: Revoca di un attributo certificato posseduto da uno specifico aderente
  Tutti gli utenti admin degli enti certificatori possono revocare uno degli attributi certificati che hanno assegnato precedentemente

  @tenant-revoke-certified-attribute1
  Scenario Outline: Per un attributo precedentemente certificato da un aderente, il quale ha la qualifica di ente certificatore (certifier), che lo assegna ad un altro ente, alla richiesta di revoca da parte di un utente con sufficienti permessi (admin), va a buon fine, altrimenti ottiene un errore
    Given l'utente è un "<ruolo>" di "PA2"
    Given "PA2" ha creato un attributo certificato e lo ha assegnato a "PA1"
    When l'utente revoca l'attributo precedentemente creato e assegnato
    Then si ottiene status code <statusCode>

    Examples:
      | ruolo        | statusCode |
      | admin        |        204 |
      | api          |        403 |
      | security     |        403 |
      | support      |        403 |
      | api,security |        403 |

  @tenant-revoke-certified-attribute2a
  Scenario Outline: Per un attributo precedentemente certificato da un primo aderente, il quale ha la qualifica di ente certificatore (certifier), che lo assegna ad un secondo ente, alla richiesta di revoca da parte di un utente con sufficienti permessi (admin) appartenente ad un terzo ente certificatore, ottiene un errore
    Given l'utente è un "admin" di "GSP2"
    Given "PA2" ha creato un attributo certificato e lo ha assegnato a "GSP"
    When l'utente revoca l'attributo precedentemente creato e assegnato
    Then si ottiene status code 403
