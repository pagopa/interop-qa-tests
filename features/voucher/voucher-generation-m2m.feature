@voucher_generation_m2m
Feature: Generazione del voucher m2m richiesta da un Ente

  @voucher_generation_m2m1
  Scenario Outline: La generazione del JWT va a buon fine quando i parametri sono validi
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "API"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher M2M
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_m2m2
  Scenario Outline: La generazione del JWT va a buon fine quando viene aggiunta una nuova chiave al client
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "API"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given un "admin" di "PA1" ha aggiunto una nuova chiave pubblica al client
    When l'utente richiede la generazione del voucher M2M
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_m2m3
  Scenario Outline: La generazione del JWT va a buon fine quando viene rimossa una chiave dal client
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "API"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given un "admin" di "PA1" ha aggiunto una nuova chiave pubblica al client
    Given "PA1" rimuove quella nuova chiave dal client 
    When l'utente richiede la generazione del voucher M2M
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_m2m4
  Scenario Outline: La generazione del JWT fallisce quando l’unica chiave presente viene rimossa dal client
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "API"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" rimuove quella chiave dal client 
    When l'utente richiede la generazione del voucher M2M
    Then la richiesta di generazione del Voucher non va a buon fine

@voucher_generation_m2m5
Scenario Outline: La generazione del JWT fallisce quando una chiave viene rimossa dal client
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "API"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given un "admin" di "PA1" ha aggiunto una nuova chiave pubblica al client
    Given "PA1" rimuove quella chiave dal client
    When l'utente richiede la generazione del voucher M2M
    Then si ottiene la corretta generazione del voucher

@voucher_generation_m2m6
Scenario Outline: La generazione del JWT fallisce quando la chiave non è associata al client richiesto
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "API"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già creato una nuova chiave pubblica senza associarla al client
    When l'utente richiede la generazione del voucher M2M
    Then la richiesta di generazione del Voucher non va a buon fine

@voucher_generation_m2m7
Scenario Outline: La generazione del JWT fallisce quando il client viene cancellato
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "API"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" cancella quel client
    When l'utente richiede la generazione del voucher M2M
    Then la richiesta di generazione del Voucher non va a buon fine