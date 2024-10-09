@tenant_update_verified_expiration_date
Feature: Aggiornamento della data di scadenza di un attributo verificato ad un aderente
  Tutti gli utenti autorizzati di enti che possono erogare eservice possono aggiornare la data di scadenza di un proprio attributo verificato

  @tenant_update_verified_expiration_date1 @no-parallel
  Scenario Outline: Per un attributo verificato precedentemente creato e assegnato da un primo aderente ad un secondo aderente, alla richiesta di aggiornamento di un attributo che non ha data di scadenza ad una data nel futuro da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato un attributo verificato
    Given "<ente>" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "MANUAL"
    Given "PA2" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given "<ente>" ha già verificato l'attributo verificato a "PA2"
    When l'utente richiede l'aggiornamento di quell'attributo di "PA2" con una data di scadenza nel futuro
    Then si ottiene status code <statusCode>

    Examples:
      | ente | ruolo        | statusCode |
      | PA1  | admin        |        204 |
      | PA1  | api          |        403 |
      | PA1  | security     |        403 |
      | PA1  | support      |        403 |
      | PA1  | api,security |        403 |
      | GSP  | admin        |        204 |
      | GSP  | api          |        403 |
      | GSP  | security     |        403 |
      | GSP  | support      |        403 |
      | GSP  | api,security |        403 |

  @tenant_update_verified_expiration_date2 @no-parallel
  Scenario Outline: Per un attributo verificato precedentemente creato e assegnato da un primo aderente ad un secondo aderente, alla richiesta di aggiornamento di un attributo che ha già una scadenza ad un’altra data nel futuro da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un attributo verificato
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "MANUAL"
    Given "PA2" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given "PA1" ha già verificato l'attributo verificato a "PA2" con una data di scadenza nel futuro
    When l'utente richiede l'aggiornamento di quell'attributo di "PA2" con una data di scadenza nel futuro
    Then si ottiene status code 204

  @tenant_update_verified_expiration_date3 @no-parallel
  Scenario Outline: Per un attributo verificato precedentemente creato e assegnato da un primo aderente ad un secondo aderente, alla richiesta di aggiornamento di un attributo che ha già una scadenza rimuovendo la scadenza (expirationDate == undefined) da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un attributo verificato
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "MANUAL"
    Given "PA2" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given "PA1" ha già verificato l'attributo verificato a "PA2" con una data di scadenza nel futuro
    When l'utente richiede l'aggiornamento di quell'attributo di "PA2" rimuovendo la data di scadenza
    Then si ottiene status code 204

  @tenant_update_verified_expiration_date4
  Scenario Outline: Per un attributo verificato precedentemente creato e assegnato da un primo aderente ad un secondo aderente, alla richiesta di aggiornamento di un attributo ad una data nel passato da parte di un utente con sufficienti permessi (admin) appartenente al primo aderente, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un attributo verificato
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "MANUAL"
    Given "PA2" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given "PA1" ha già verificato l'attributo verificato a "PA2"
    When l'utente richiede l'aggiornamento di quell'attributo di "PA2" con una data di scadenza nel passato
    Then si ottiene status code 400
