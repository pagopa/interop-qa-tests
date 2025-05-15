@tenant_revoke_certified_attribute
Feature: Revoca di un attributo certificato posseduto da uno specifico aderente
  Tutti gli utenti autorizzati degli enti certificatori possono revocare uno degli attributi certificati che hanno assegnato precedentemente

  @tenant_revoke_certified_attribute1 @no-parallel
  Scenario Outline: Per un attributo certificato precedentemente creato da un aderente, il quale ha la qualifica di ente certificatore (certifier), che lo assegna ad un altro ente, alla richiesta di revoca da parte di un utente con sufficienti permessi (admin), va a buon fine, altrimenti ottiene un errore
    Given l'utente è un "<ruolo>" di "PA2"
    Given "PA2" ha creato un attributo certificato e lo ha assegnato a "PA1"
    When l'utente revoca l'attributo precedentemente creato e assegnato
    Then si ottiene status code <statusCode>

    Examples:
      | ruolo        | statusCode |
      # | admin        |        204 |
      # | api          |        403 |
      # | security     |        403 |
      # | support      |        403 |
      | api,security |        403 |

  @tenant_revoke_certified_attribute2
  Scenario Outline: Per un attributo certificato precedentemente creato da un primo aderente, il quale ha la qualifica di ente certificatore (certifier), che lo assegna ad un secondo ente, alla richiesta di revoca da parte di un utente con sufficienti permessi (admin) appartenente ad un terzo ente certificatore, ottiene un errore
    Given l'utente è un "admin" di "GSP2"
    Given "PA2" ha creato un attributo certificato e lo ha assegnato a "GSP"
    When l'utente revoca l'attributo precedentemente creato e assegnato
    Then si ottiene status code 403
