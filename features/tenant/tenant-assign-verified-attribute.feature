@tenant_assign_verified_attribute
Feature: Assegnazione di un attributo verificato ad un aderente
  Tutti gli utenti admin di enti non Privati possono assegnare un attributo verificato

  @tenant_assign_verified_attribute1
  Scenario Outline: Per un attributo verificato precedentemente creato da un primo aderente, alla richiesta di assegnazione dell’attributo senza data di scadenza ad un secondo aderente da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 attributo "VERIFIED"
    When l'utente assegna a "PA2" l'attributo certificato precedentemente creato
    Then si ottiene status code <statusCode>

    Examples:
      | ente | ruolo        | statusCode |
      | PA1  | admin        |        200 |
      | PA1  | api          |        400 |
      | PA1  | security     |        400 |
      | PA1  | support      |        400 |
      | PA1  | api,security |        400 |
      | GSP  | admin        |        200 |
      | GSP  | api          |        400 |
      | GSP  | security     |        400 |
      | GSP  | support      |        400 |
      | GSP  | api,security |        400 |

  @tenant_assign_verified_attribute2
  Scenario Outline: Per un attributo certificato precedentemente creato da un aderente, il quale ha la qualifica di ente certificatore (certifier), alla richiesta di assegnazione dell’attributo all’ente stesso da parte di un utente con sufficienti permessi (admin), ottiene un errore. Spiegazione: un ente non può autoassegnarsi attributi certificati
    Given l'utente è un "admin" di "PA2"
    Given "PA2" ha già creato 1 attributo "CERTIFIED"
    When l'utente assegna a "PA2" l'attributo certificato precedentemente creato
    Then si ottiene status code 400

  @tenant_assign_verified_attribute3
  Scenario Outline: Per un attributo certificato precedentemente creato da un primo aderente, alla richiesta di assegnazione dell’attributo ad un secondo ente da parte di un utente con sufficienti permessi (admin), il quale admin appartiene ad un terzo aderente, il quale ha la qualifica di ente certificatore (certifier), ottiene un errore (NB: verificare status code). Spiegazione: un ente non può assegnare attributi certificati che non ha creato
    Given l'utente è un "admin" di "enteCertificatore"
    Given "PA2" ha già creato 1 attributo "CERTIFIED"
    When l'utente assegna a "GSP" l'attributo certificato precedentemente creato
    Then si ottiene status code 400
