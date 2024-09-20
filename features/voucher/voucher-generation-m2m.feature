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
