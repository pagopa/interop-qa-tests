@voucher_generation
Feature: Generazione del voucher richiesta da un Ente

  @voucher_generation1
  Scenario Outline: La generazione del Voucher va a buon fine quando gli oggetti sono attivi e la chiave pubblica è valida
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "<ente>" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già associato la finalità a quel client
    Given un "<ruolo>" di "<ente>" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

 Examples:
      | ente | ruolo        |
      | GSP  | admin        |
      # | GSP  | api          |
      # | GSP  | security     |
      # | GSP  | support      |
      # | GSP  | api,security |
      # | PA1  | admin        |
      # | PA1  | api          |
      # | PA1  | security     |
      # | PA1  | support      |
      # | PA1  | api,security |