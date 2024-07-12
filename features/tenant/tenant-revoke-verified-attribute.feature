@tenant_revoke_verified_attribute
Feature: Revoca di un attributo verificato posseduto da uno specifico aderente
  Tutti gli utenti autorizzati degli enti erogatori possono revocare uno degli attributi verificati che hanno assegnato precedentemente

  @tenant_revoke_verified_attribute1
  Scenario Outline: Per un attributo precedentemente verificato da un primo aderente ad un secondo aderente, alla richiesta di revoca da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, va a buon fine
    Given l'utente è un "<ruolo>" di "PA2"
    Given "PA2" crea un attributo verificato
    Given "PA2" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "MANUAL"
    Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given "PA2" verifica l'attributo verificato a "PA1"
    When l'utente revoca l'attributo precedentemente verificato
    Then si ottiene status code <statusCode>

    Examples:
      | ruolo        | statusCode |
      | admin        |        204 |
      | api          |        403 |
      | security     |        403 |
      | support      |        403 |
      | api,security |        403 |

  @tenant_revoke_verified_attribute2
  Scenario Outline: Per un attributo precedentemente verificato da un primo aderente ad un secondo aderente, e poi successivamente verificato da un terzo aderente sempre al secondo aderente, alla richiesta di revoca da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, va a buon fine. Inoltre, l’istanza dell’attributo verificato dal terzo aderente rimane verificata
    Given l'utente è un "admin" di "PA2"
    Given "PA2" crea un attributo verificato
    Given "PA2" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "MANUAL"
    Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given "PA2" verifica l'attributo verificato a "PA1"
    Given "GSP" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "MANUAL"
    Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given "GSP" verifica l'attributo verificato a "PA1"
    When l'utente revoca l'attributo precedentemente verificato
    Then si ottiene status code 204
    And l'attributo di "PA1" rimane verificato da "GSP"
    And l'attributo di "PA1" risulta revocato da "PA2"
