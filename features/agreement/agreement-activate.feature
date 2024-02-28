@agreement_activate
Feature: Attivazione richiesta di fruizione

  @agreement_activate1
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato PENDING (prima attivazione), con tutti gli attributi richiesti certificati, tutti gli attributi richiesti dichiarati dal fruitore, e tutti gli attributi richiesti verificati dall’erogatore, alla richiesta di attivazione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, va a buon fine
    Given l'utente è un "<ruolo>" di "<enteFruitore>"
    Given "<enteFruitore>" possiede un attributo certificato
    Given "<enteFruitore>" possiede un attributo verificato da "PA1"
    Given "<enteFruitore>" possiede un attributo dichiarato
    Given un "admin" di "PA1" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "MANUAL"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    When l'utente richiede una operazione di attivazione di quella richiesta di fruizione
    Then si ottiene status code 200
 
    Examples: 
      | enteFruitore | ruolo        | risultato |
      | GSP          | admin        |       200 |
      | GSP          | api          |       403 |
      | GSP          | security     |       403 |
      | GSP          | support      |       403 |
      | GSP          | api,security |       403 |
      | PA1          | admin        |       200 |
      | PA1          | api          |       403 |
      | PA1          | security     |       403 |
      | PA1          | support      |       403 |
      | PA1          | api,security |       403 |
      | PA2          | admin        |       200 |
      | PA2          | api          |       403 |
      | PA2          | security     |       403 |
      | PA2          | support      |       403 |
      | PA2          | api,security |       403 |
      | Privato      | admin        |       200 |
      | Privato      | api          |       403 |
      | Privato      | security     |       403 |
      | Privato      | support      |       403 |
      | Privato      | api,security |       403 |



@agreement_activate2
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato SUSPENDED (riattivazione), con tutti gli attributi richiesti certificati, tutti gli attributi richiesti dichiarati dal fruitore, e tutti gli attributi richiesti verificati dall’erogatore, alla richiesta di attivazione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, va a buon fine. NB: la richiesta va a buon fine ma è possibile che la richiesta di fruizione non cambi stato. Qui si verifica solo che l’endpoint restituisca successo, non l’eventuale cambio di stato della richiesta di fruizione in polling

    Given l'utente è un "admin" di "PA1"
    Given "PA1" possiede un attributo certificato
    Given "PA1" possiede un attributo verificato da "PA1"
    Given "PA1" possiede un attributo dichiarato
    Given un "admin" di "PA1" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "AUTOMATIC"
    Given "PA1" ha una richiesta di fruizione in stato "SUSPENDED" per quell'e-service
    When l'utente richiede una operazione di attivazione di quella richiesta di fruizione
    Then si ottiene status code 200

  @agreement_activate3
  Scenario Outline:  Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato PENDING o SUSPENDED; con tutti gli attributi richiesti certificati, i quali sono due gruppi di due, dei quali il fruitore ne possiede uno per gruppo; tutti gli attributi richiesti dichiarati dal fruitore, i quali sono due gruppi di due, dei quali il fruitore ne possiede uno per gruppo; tutti gli attributi richiesti verificati dall’erogatore, i quali sono due gruppi di due, dei quali il fruitore ne possiede uno per gruppo; alla richiesta di attivazione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, va a buon fine. NB: Questa è un’apparente duplicato del primo test. Nel primo test si verifica solo che in una situazione “base”, la richiesta di fruizione vada a buon fine; qui si stressa il meccanismo di calcolo di AND/OR degli attributi e si verifica che funzioni correttamente

    Given l'utente è un "<ruolo>" di "<enteFruitore>"
    Given due gruppi di due attributi certificati da "PA2", dei quali "PA1" ne possiede uno per gruppo
    Given due gruppi di due attributi verificati, dei quali "PA1" ne possiede uno per gruppo
    Given due gruppi di due attributi dichiarati, dei quali "PA1" ne possiede uno per gruppo
    Given un "admin" di "PA1" ha già creato un e-service in stato "<AgreementState>" che richiede quei gruppi di attributi con approvazione "MANUAL"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    When l'utente richiede una operazione di attivazione di quella richiesta di fruizione
    Then si ottiene status code 200

@agreement_activate4
  Scenario Outline:  Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato ACTIVE, REJECTED, ARCHIVED o MISSING_CERTIFIED_ATTRIBUTES, con tutti gli attributi richiesti certificati, tutti gli attributi richiesti dichiarati dal fruitore, e tutti gli attributi richiesti verificati dall’erogatore, alla richiesta di attivazione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, ottiene un errore (NB: verificare status code)

    Given l'utente è un "<ruolo>" di "<enteFruitore>"
    Given due gruppi di due attributi certificati da "PA2", dei quali "PA1" ne possiede uno per gruppo
    Given due gruppi di due attributi verificati, dei quali "PA1" ne possiede uno per gruppo
    Given due gruppi di due attributi dichiarati, dei quali "PA1" ne possiede uno per gruppo
    Given un "admin" di "PA1" ha già creato un e-service in stato "<AgreementState>" che richiede quei gruppi di attributi con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "<state>" per quell'e-service
    When l'utente richiede una operazione di attivazione di quella richiesta di fruizione
    Then si ottiene status code 200