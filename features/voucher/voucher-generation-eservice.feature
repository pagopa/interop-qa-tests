@voucher_generation_eservice
Feature: Generazione del voucher richiesta da un Ente

  @voucher_generation_eservice1
  Scenario Outline: La generazione del Voucher va a buon fine per una Versione deprecata dell'EService
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA2" ha già pubblicato una nuova versione per quell'e-service
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_eservice2
  Scenario Outline: La generazione del Voucher va a buon fine per una Versione pubblicata dell'EService, quando esiste una versione precedente deprecata
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già pubblicato una nuova versione per quell'e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_eservice3
  Scenario Outline: La generazione del Voucher va a buon fine per una Versione pubblicata dell'EService, quando la precedente è stata archiviata in seguito alla pubblicazione
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA2" ha già pubblicato una nuova versione per quell'e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_eservice4
  Scenario Outline: La generazione del Voucher va a buon fine per una Versione pubblicata dell'EService, quando esiste una Versione precedente sospesa
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA2" ha già sospeso quell'e-service
    Given "PA2" ha già pubblicato una nuova versione per quell'e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_eservice5
  Scenario Outline: La generazione del Voucher va a buon fine per una Versione deprecata dell'EService quando la Versione più recente è sospesa
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA2" ha già pubblicato una nuova versione per quell'e-service
    Given "PA2" ha già sospeso quell'e-service
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_eservice6
  Scenario Outline: La generazione del Voucher va a buon fine per una Versione pubblicata dell'EService quando esiste una Versione più recente in bozza
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA2" ha già una nuova versione in stato DRAFT per quell'e-service
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_eservice7
  Scenario Outline: La generazione del Voucher va a buon fine per una Versione sospesa e poi riattivata dell'EService
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA2" ha già sospeso quell'e-service
    Given "PA2" ha già attivato nuovamente quell'e-service
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_eservice8
  Scenario Outline: La generazione del Voucher va a buon fine per una Versione deprecata dell'EService che viene sospesa e poi riattivata
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA2" ha già pubblicato una nuova versione per quell'e-service
    Given "PA2" ha già sospeso la vecchia versione di quell'e-service
    Given "PA2" ha già attivato nuovamente la vecchia versione quell'e-service
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_eservice9
  Scenario Outline: La generazione del Voucher fallisce per una Versione sospesa dell'EService quando esiste una Versione più recente in bozza
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA2" ha già sospeso quell'e-service 
    Given "PA2" ha già una nuova versione in stato DRAFT per quell'e-service
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_eservice10
  Scenario Outline: La generazione del Voucher fallisce per una Versione sospesa dell'EService quando esiste una Versione precedente deprecata
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già pubblicato una nuova versione per quell'e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA2" ha già sospeso quell'e-service
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_eservice11
  Scenario Outline: La generazione del Voucher fallisce per una Versione sospesa dell'EService quando esiste una Versione più recente pubblicata
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già pubblicato una nuova versione per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA2" ha già sospeso la vecchia versione di quell'e-service
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

  # TODO Archiviazione manuale?
  #  @voucher_generation_eservice12
  # Scenario Outline: La generazione del Voucher fallisce per una Versione dell'EService manualmente archiviata
  #   Given l'utente è un "admin" di "PA1"
  #   Given "PA2" ha già creato e pubblicato 1 e-service
  #   Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
  #   Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
  #   Given "PA1" ha già creato 1 client "CONSUMER"
  #   Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
  #   Given "PA1" ha già associato la finalità a quel client
  #   Given un "admin" di "PA1" ha caricato una chiave pubblica nel client

  #   When l'utente richiede la generazione del voucher
  #   Then si ottiene la corretta generazione del voucher
