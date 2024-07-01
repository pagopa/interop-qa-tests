@tenant-revoke-declared-attribute
Feature: Revoca di un attributo dichiarato posseduto da uno specifico aderente
  Tutti gli utenti autenticati degli enti erogatori possono revocare uno degli attributi dichiarati che si sono precedentemente assegnati

  @tenant-revoke-declared-attribute1
  Scenario Outline: Per un attributo precedentemente dichiarato dall’aderente stesso, alla richiesta di revoca da parte di un utente con sufficienti permessi (admin) appartenente a quell'ente, va a buon fine
    Given l'utente è un "<ruolo>" di "PA2"
    Given "PA2" dichiara un attributo dichiarato
    When l'utente revoca l'attributo precedentemente dichiarato
    Then si ottiene status code <statusCode>

    Examples:
      | ruolo        | statusCode |
      | admin        |        204 |
      | api          |        403 |
      | security     |        403 |
      | support      |        403 |
      | api,security |        403 |
