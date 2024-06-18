@tenant-revoke-verified-attribute
Feature: Revoca di un attributo verificato posseduto da uno specifico aderente
  Tutti gli utenti autenticati degli enti erogatori possono revocare uno degli attributi verificati che hanno assegnato precedentemente

  @tenant-revoke-verified-attribute1
  Scenario Outline: Per un attributo precedentemente verificato da un primo aderente ad un secondo aderente, alla richiesta di revoca da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, va a buon fine
    Given l'utente è un "<ruolo>" di "PA2"
    Given "PA1" crea un attributo verificato
    Given "PA2" verifica l'attributo verificato a "PA1"
    When l'utente revoca l'attributo precedentemente verificato
    Then si ottiene status code <statusCode>

    Examples:
      | ruolo        | statusCode |
      | admin        |        200 |
      | api          |        400 |
      | security     |        400 |
      | support      |        400 |
      | api,security |        400 |

  @tenant-revoke-verified-attribute2
  Scenario Outline: Per un attributo precedentemente verificato da un primo aderente ad un secondo aderente, e poi successivamente verificato da un terzo aderente sempre al secondo aderente, alla richiesta di revoca da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, va a buon fine. Inoltre, l’istanza dell’attributo verificato dal terzo aderente rimane verificata
     Given l'utente è un "<ruolo>" di "PA2"
    Given "PA1" crea un attributo verificato
    Given "PA2" verifica l'attributo verificato a "PA1"
    Given "GSP" verifica l'attributo verificato a "PA1"
    When l'utente revoca l'attributo precedentemente verificato
    Then si ottiene status code 200 e l'attributo rimane verificato da "GSP"
