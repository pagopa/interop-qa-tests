@tenant_update_verified_expiration_date
Feature: Aggiornamento della data di scadenza di un attributo verificato ad un aderente
  Tutti gli utenti admin di enti non Privati possono aggiornare la data di scadenza di un proprio attributo verificato

  @tenant_update_verified_expiration_date1
  Scenario Outline: Per un attributo verificato precedentemente creato e assegnato da un primo aderente ad un secondo aderente, alla richiesta di aggiornamento di un attributo che non ha data di scadenza ad una data nel futuro da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" crea un attributo verificato
    Given "<ente>" verifica l'attributo verificato a "PA2"
    When l'utente richiede l'aggiornamento di quell'attributo con una data di scadenza nel futuro
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

  @tenant_update_verified_expiration_date2
  Scenario Outline: Per un attributo verificato precedentemente creato e assegnato da un primo aderente ad un secondo aderente, alla richiesta di aggiornamento di un attributo che ha già una scadenza ad un’altra data nel futuro da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA1" crea un attributo verificato
    Given "PA1" verifica l'attributo verificato a "PA2" con una data di scadenza nel futuro
    When l'utente richiede l'aggiornamento di quell'attributo con una data di scadenza nel futuro
    Then si ottiene status code 200

  @tenant_update_verified_expiration_date3
  Scenario Outline: Per un attributo verificato precedentemente creato e assegnato da un primo aderente ad un secondo aderente, alla richiesta di aggiornamento di un attributo che ha già una scadenza rimuovendo la scadenza (expirationDate == undefined) da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA1" crea un attributo verificato
    Given "PA1" verifica l'attributo verificato a "PA2" con una data di scadenza nel futuro
    When l'utente richiede l'aggiornamento di quell'attributo rimuovendo la data di scadenza
    Then si ottiene status code 200

  @tenant_update_verified_expiration_date4
  Scenario Outline: Per un attributo verificato precedentemente creato e assegnato da un primo aderente ad un secondo aderente, alla richiesta di aggiornamento di un attributo ad una data nel passato da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" crea un attributo verificato
    Given "PA1" verifica l'attributo verificato a "PA2"
    When l'utente richiede l'aggiornamento di quell'attributo con una data di scadenza nel passato
    Then si ottiene status code 400
