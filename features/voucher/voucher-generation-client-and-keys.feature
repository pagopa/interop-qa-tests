@voucher_generation_client_and_keys
Feature: Generazione del voucher sulla creazione del client e sul caricamento della chiave

@voucher_generation_client_and_keys1
Scenario Outline: La generazione del Voucher va a buon fine quando viene aggiunta una nuova chiave al client
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha aggiunto una nuova chiave pubblica al client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

@voucher_generation_client_and_keys2
Scenario Outline: La generazione del Voucher va a buon fine quando viene rimossa una chiave dal client
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha aggiunto una nuova chiave pubblica al client
    Given "PA1" rimuove quella nuova chiave dal client 
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

@voucher_generation_client_and_keys3
Scenario Outline: La generazione del Voucher va a buon fine quando viene aggiunta una nuova finalità al client
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già associato la finalità a quel client
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già associato la finalità a quel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

@voucher_generation_client_and_keys4 @no-parallel
Scenario Outline: La generazione del Voucher va a buon fine quando viene rimossa una finalità dal client
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già associato la finalità a quel client
    Given "PA1" ha già creato una nuova finalità attiva per quell'eservice
    Given "PA1" ha già associato quella nuova finalità a quel client
    Given "PA1" rimuove quella nuova finalità dal client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

@voucher_generation_client_and_keys5
Scenario Outline: La generazione del Voucher va a buon fine quando la finalità viene aggiunta dopo la chiave
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già associato la finalità a quel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

@voucher_generation_client_and_keys6
Scenario Outline: La generazione del Voucher va a buon fine quando la finalità viene aggiunta prima della chiave
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

@voucher_generation_client_and_keys7
Scenario Outline: La generazione del Voucher va a buon fine quando l’unica finalità viene rimossa e una nuova finalità viene aggiunta
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già associato la finalità a quel client
    Given "PA1" rimuove quella finalità dal client
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già associato la finalità a quel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

@voucher_generation_client_and_keys8
Scenario Outline: La generazione del Voucher fallisce quando l’unica chiave presente viene rimossa dal client
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" rimuove quella chiave dal client 
    When l'utente richiede la generazione del voucher 
    Then la richiesta di generazione del Voucher non va a buon fine

@voucher_generation_client_and_keys9
Scenario Outline: La generazione del Voucher fallisce quando la chiave viene rimossa dal client
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given un "admin" di "PA1" ha aggiunto una nuova chiave pubblica al client
    Given "PA1" rimuove quella chiave dal client 
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

@voucher_generation_client_and_keys10
Scenario Outline: La generazione del Voucher fallisce quando l’unica finalità presente viene rimossa dal client
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già associato la finalità a quel client
    Given "PA1" rimuove quella finalità dal client
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

@voucher_generation_client_and_keys11
Scenario Outline: La generazione del Voucher fallisce quando la finalità viene rimossa dal client
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato una nuova finalità attiva per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già associato la finalità a quel client
    Given "PA1" ha già associato quella nuova finalità a quel client
    Given "PA1" rimuove quella finalità dal client
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

@voucher_generation_client_and_keys12
Scenario Outline: La generazione del Voucher fallisce quando la chiave non è associata a un client
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già associato la finalità a quel client
    Given "PA1" ha già creato una nuova chiave pubblica senza associarla al client
    When l'utente richiede la generazione del voucher 
    Then la richiesta di generazione del Voucher non va a buon fine

@voucher_generation_client_and_keys13
Scenario Outline: La generazione del Voucher fallisce quando la chiave non è associata al client richiesto
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già creato 1 nuovo client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel nuovo client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel nuovo client
    Given "PA1" ha già associato la finalità a quel client
    Given "PA1" ha già associato la finalità al nuovo client
    When l'utente richiede la generazione del voucher indicando il primo client ma con la chiave caricata nel secondo
    Then la richiesta di generazione del Voucher non va a buon fine

@voucher_generation_client_and_keys14
Scenario Outline: La generazione del Voucher fallisce quando il client viene cancellato
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" cancella quel client
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine