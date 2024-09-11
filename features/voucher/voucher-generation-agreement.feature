@voucher_generation_agreement
Feature: Generazione del voucher sulle richieste di fruizione

@voucher_generation_agreement1
Scenario Outline: La generazione del Voucher va a buon fine quando la richiesta di fruizione viene sospesa e poi riattivata dall’erogatore
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già sospeso quella richiesta di fruizione come "PRODUCER"
    Given "GSP" ha già attivato nuovamente quella richiesta di fruizione
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

@voucher_generation_agreement2
Scenario Outline: La generazione del Voucher va a buon fine quando la richiesta di fruizione viene sospesa e poi riattivata dal fruitore
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già sospeso quella richiesta di fruizione come "CONSUMER"
    Given "PA1" ha già attivato nuovamente quella richiesta di fruizione
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

@voucher_generation_agreement3
Scenario Outline: La generazione del Voucher va a buon fine quando la richiesta di fruizione viene sospesa dall’erogatore e dal fruitore, e poi riattivata sia dall’erogatore che dal fruitore
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già sospeso quella richiesta di fruizione come "PRODUCER"
    Given "GSP" ha già attivato nuovamente quella richiesta di fruizione
    Given "PA1" ha già sospeso quella richiesta di fruizione come "CONSUMER"
    Given "PA1" ha già attivato nuovamente quella richiesta di fruizione
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

@voucher_generation_agreement4
Scenario Outline: La generazione del Voucher va a buon fine quando il fruitore perde e poi riottiene un attributo certificato necessario all’utilizzo dell’EService
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha creato un attributo certificato e lo ha assegnato a "PA1"
    Given "GSP" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "PA2" ha già revocato quell'attributo "CERTIFIED" a "PA1"
    Given "PA2" ha già assegnato nuovamente quell'attributo "CERTIFIED" a "PA1"
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

@voucher_generation_agreement5
Scenario Outline: La generazione del Voucher va a buon fine quando il fruitore perde e poi riottiene un attributo verificato necessario all’utilizzo dell’EService
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un attributo verificato
    Given "PA2" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "AUTOMATIC"
    Given "PA2" ha già revocato quell'attributo "VERIFIED" a "PA1"
    Given "PA2" ha già assegnato nuovamente quell'attributo "VERIFIED" a "PA1"
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

@voucher_generation_agreement6 
Scenario Outline: La generazione del Voucher va a buon fine quando il fruitore perde e poi riottiene un attributo dichiarato necessario all’utilizzo dell’EService
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già dichiarato un attributo
    Given "PA2" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "AUTOMATIC"
    Given "PA1" ha già revocato quell'attributo "DECLARED" a "PA1"
    Given "PA1" ha già dichiarato nuovamente quell'attributo "DECLARED" a "PA1"
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

# @voucher_generation_agreement7
# Scenario Outline: La generazione del Voucher va a buon fine quando la richiesta di fruizione attiva subisce un upgrade verso una Versione dell’EService più recente, e l’upgrade viene completato direttamente
#     Given l'utente è un "admin" di "PA1"
#     Given "PA2" ha creato un attributo certificato e lo ha assegnato a "PA1"
#     Given "GSP" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
#     Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
#     Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
#     Given "PA1" ha già creato 1 client "CONSUMER"
#     Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
#     Given "PA1" ha già associato la finalità a quel client
#     Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
#     Given "PA2" ha già pubblicato una nuova versione per quell'e-service
#     Given la richiesta di fruizione è stata aggiornata all'ultima versione dell'eservice
#     When l'utente richiede la generazione del voucher
#     Then si ottiene la corretta generazione del voucher

# @voucher_generation_agreement8
# Scenario Outline: La generazione del Voucher va a buon fine quando la richiesta di fruizione attiva subisce un upgrade verso una Versione dell’EService più recente, e la richiesta rimane in attesa di approvazione
#     Given l'utente è un "admin" di "PA1"
#     Given "PA2" ha creato un attributo certificato e lo ha assegnato a "PA1"
#     Given "GSP" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "MANUAL"
#     Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
#     Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
#     Given "PA1" ha già creato 1 client "CONSUMER"
#     Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
#     Given "PA1" ha già associato la finalità a quel client
#     Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
#     Given "PA2" ha già pubblicato una nuova versione per quell'e-service
#     Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
#     When l'utente richiede la generazione del voucher
#     Then si ottiene la corretta generazione del voucher