@tenant_assign_certified_attribute
Feature: Assegnazione di un attributo certificato ad un aderente
  Tutti gli utenti admin degli enti certificatori possono assegnare un attributo certificato

  @tenant_assign_certified_attribute1
  Scenario Outline: Per un attributo certificato precedentemente creato da un aderente, il quale ha la qualifica di ente certificatore (certifier), alla richiesta di assegnazione dell’attributo ad un altro ente da parte di un utente con sufficienti permessi (admin), va a buon fine
    Given l'utente è un "<ruolo>" di "PA2"
    Given "PA2" ha già creato 1 attributo "CERTIFIED"
    When l'utente assegna a "PA1" l'attributo certificato precedentemente creato
    Then si ottiene status code <statusCode>

    Examples:
      | ruolo        | statusCode |
      | admin        |        204 |
      | api          |        403 |
      | security     |        403 |
      | support      |        403 |
      | api,security |        403 |

  @tenant_assign_certified_attribute2 @wait_for_fix
  Scenario Outline: Per un attributo certificato precedentemente creato da un aderente, il quale ha la qualifica di ente certificatore (certifier), alla richiesta di assegnazione dell’attributo all’ente stesso da parte di un utente con sufficienti permessi (admin), ottiene un errore. Spiegazione: un ente non può autoassegnarsi attributi certificati
    Given l'utente è un "admin" di "PA2"
    Given "PA2" ha già creato 1 attributo "CERTIFIED"
    When l'utente assegna a "PA2" l'attributo certificato precedentemente creato
    Then si ottiene status code 400

  @tenant_assign_certified_attribute3
  Scenario Outline: Per un attributo certificato precedentemente creato da un primo aderente, alla richiesta di assegnazione dell’attributo ad un secondo ente da parte di un utente con sufficienti permessi (admin), il quale admin appartiene ad un terzo aderente, il quale ha la qualifica di ente certificatore (certifier), ottiene un errore (NB: verificare status code). Spiegazione: un ente non può assegnare attributi certificati che non ha creato
    Given l'utente è un "admin" di "enteCertificatore"
    Given "PA2" ha già creato 1 attributo "CERTIFIED"
    When l'utente assegna a "GSP" l'attributo certificato precedentemente creato
    Then si ottiene status code 400
