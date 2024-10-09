@voucher_generation_params_validation
Feature: Generazione del voucher richiesta da un Ente

  @voucher_generation_params_validation1
  Scenario Outline: La generazione del Voucher fallisce quando il parametro client_assertion_type non ha il valore atteso
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher con il parametro "client_assertion_type" diverso da quello atteso
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_params_validation2
  Scenario Outline: La generazione del Voucher fallisce quando il parametro grant_type non ha il valore atteso
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher con il parametro "grant_type" diverso da quello atteso
    Then la richiesta di generazione del Voucher non va a buon fine per il parametro grant_type

  @voucher_generation_params_validation3
  Scenario Outline: La generazione del Voucher fallisce quando il parametro client_id è diverso dal claim sub nella client assertion
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher valorizzando il parametro client_id con un valore diverso dal claim sub nella client assertion
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_params_validation4
  Scenario Outline: La generazione del Voucher fallisce quando la client assertion non è un JWT valido
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher inserendo una client assertion come JWT non valida
    Then la richiesta di generazione del Voucher non va a buon fine

 