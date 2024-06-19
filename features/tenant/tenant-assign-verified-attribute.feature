@tenant_assign_verified_attribute
Feature: Assegnazione di un attributo verificato ad un aderente
  Tutti gli utenti admin di enti non Privati possono assegnare un attributo verificato

  @tenant_assign_verified_attribute1
  Scenario Outline: Per un attributo verificato precedentemente creato da un primo aderente, alla richiesta di assegnazione dell’attributo senza data di scadenza ad un secondo aderente da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 attributo "VERIFIED"
    When l'utente assegna a "PA2" l'attributo verificato precedentemente creato
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
  Scenario Outline: Per un attributo verificato precedentemente creato da un primo aderente, alla richiesta di assegnazione dell’attributo senza data di scadenza ad un secondo aderente da parte di un utente con sufficienti permessi (admin) appartenente al terzo aderente, va a buon fine. Spiega: gli attributi verificati possono essere assegnati indipendentemente da chi li ha creati
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato 1 attributo "VERIFIED"
    When l'utente assegna a "GSP" l'attributo verificato precedentemente creato
    Then si ottiene status code 200

  @tenant_assign_verified_attribute3
  Scenario Outline: Per un attributo verificato precedentemente creato da un primo aderente, alla richiesta di assegnazione dell’attributo con data di scadenza nel futuro ad un secondo aderente da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato 1 attributo "VERIFIED"
    When l'utente assegna a "PA2" l'attributo verificato precedentemente creato con data di scadenza nel futuro
    Then si ottiene status code 200

  @tenant_assign_verified_attribute4
  Scenario Outline: Per un attributo verificato precedentemente creato da un primo aderente, alla richiesta di assegnazione dell’attributo con data di scadenza nel passato ad un secondo aderente da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato 1 attributo "VERIFIED"
    When l'utente assegna a "PA2" l'attributo verificato precedentemente creato con data di scadenza nel passato
    Then si ottiene status code 400

  @tenant_assign_verified_attribute5
  Scenario Outline: Per un attributo verificato precedentemente creato da un aderente, alla richiesta di assegnazione dell’attributo senza scadenza al proprio ente da parte di un utente con sufficienti permessi (admin), ottiene un errore. Spiega: un ente non può autoassegnarsi attributi verificati
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 attributo "VERIFIED"
    When l'utente assegna a "PA1" l'attributo verificato precedentemente creato
    Then si ottiene status code 400
