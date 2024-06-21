@tenant-revoke-certified-attribute
Feature: Revoca di un attributo certificato posseduto da uno specifico aderente
  Tutti gli utenti autenticati degli enti certificatori possono revocare uno degli attributi certificati che hanno assegnato precedentemente

  @tenant-revoke-certified-attribute1
  Scenario Outline: Per un attributo precedentemente certificato da un aderente, il quale ha la qualifica di ente certificatore (certifier), che lo assegna ad un altro ente, alla richiesta di revoca da parte di un utente con sufficienti permessi (admin), va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha creato un attributo certificato e lo ha assegnato a "PA1"
    When l'utente revoca l'attributo precedentemente creato e assegnato
    Then si ottiene status code <statusCode>

    Examples: # PA2 e GSP2
      | ente    | ruolo        | statusCode |
      | PA2     | admin        |        204 |
      | PA2     | api          |        403 |
      | PA2     | security     |        403 |
      | PA2     | support      |        403 |
      | PA2     | api,security |        403 |
      | PA1     | admin        |        403 |
      | PA1     | api          |        403 |
      | PA1     | security     |        403 |
      | PA1     | support      |        403 |
      | PA1     | api,security |        403 |
      | GSP     | admin        |        403 |
      | GSP     | api          |        403 |
      | GSP     | security     |        403 |
      | GSP     | support      |        403 |
      | GSP     | api,security |        403 |
      | Privato | admin        |        403 |
      | Privato | api          |        403 |
      | Privato | security     |        403 |
      | Privato | support      |        403 |
      | Privato | api,security |        403 |

  @tenant-revoke-certified-attribute2a
  Scenario Outline: Per un attributo precedentemente certificato da un primo aderente, il quale ha la qualifica di ente certificatore (certifier), che lo assegna ad un secondo ente, alla richiesta di revoca da parte di un utente con sufficienti permessi (admin) appartenente ad un terzo ente certificatore, ottiene un errore
    Given l'utente è un "admin" di "GSP2"
    Given "PA2" ha creato un attributo certificato e lo ha assegnato a "GSP"
    When l'utente revoca l'attributo precedentemente creato e assegnato
    Then si ottiene status code 403
