@voucher_generation_purpose
Feature: Generazione del voucher richiesta da un Ente

  @voucher_generation_purpose1
  Scenario Outline: La generazione del Voucher va a buon fine quando la finalità è attiva e ha una versione in attesa di approvazione
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_purpose2
  Scenario Outline: La generazione del Voucher va a buon fine quando la finalità è attiva, ha una versione in attesa di approvazione e questa viene eliminata
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    Given "PA1" ha già richiesto la cancellazione della richiesta di aggiornamento della stima di carico
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_purpose3
  Scenario Outline: La generazione del Voucher va a buon fine quando la finalità è attiva, ha una versione in attesa di approvazione e questa viene approvata
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    Given "PA2" ha già approvato la richiesta di aggiornamento della stima di carico
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_purpose4
  Scenario Outline: La generazione del Voucher va a buon fine quando la finalità è attiva, ha una versione in attesa di approvazione e questa viene approvata
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given l'utente ha già aggiornato finalità rispettando le stime di carico per quell'e-service
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_purpose5
  Scenario Outline: La generazione del Voucher va a buon fine quando la finalità è attiva e ha una versione in attesa di approvazione, che viene rifiutata dall’erogatore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    Given "PA2" ha già rifiutato la richiesta di aggiornamento della stima di carico
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_purpose6
  Scenario Outline: La generazione del Voucher va a buon fine quando la finalità viene sospesa e poi riattivata dall’erogatore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA2" ha già sospeso la finalità
    Given "PA2" ha già riattivato la finalità sospesa
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_purpose7
  Scenario Outline: La generazione del Voucher va a buon fine quando la finalità viene sospesa e poi riattivata dal fruitore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già sospeso la finalità
    Given "PA1" ha già riattivato la finalità sospesa
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_purpose7
  Scenario Outline: La generazione del Voucher va a buon fine quando la finalità viene sospesa dall’erogatore e dal fruitore, e poi riattivata sia dall’erogatore che dal fruitore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già sospeso la finalità
    Given "PA2" ha già sospeso la finalità
    Given "PA1" ha già riattivato la finalità sospesa
    Given "PA2" ha già riattivato la finalità sospesa
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_purpose8
  Scenario Outline: La generazione del Voucher fallisce quando la finalità è valida ma non assegnata al client
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_purpose9
  Scenario Outline: La generazione del Voucher fallisce quando la finalità è in bozza, archiviata o ha una sola versione che è in attesa di approvazione
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "<purposeState>" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    # TODO Posso associare una finalità in DRAFT, ARCHIVED o WAITING_FOR_APPROVAL, ad un client?
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

    Examples:
      | purposeState         |
      | DRAFT                |
      | ARCHIVED             |
      | WAITING_FOR_APPROVAL |

  @voucher_generation_purpose10
  Scenario Outline: La generazione del Voucher fallisce quando la finalità viene sospesa dall’erogatore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA2" ha già sospeso la finalità
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_purpose11
  Scenario Outline: La generazione del Voucher fallisce quando la finalità viene sospesa dal fruitore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già sospeso la finalità
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine
