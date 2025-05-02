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
  Scenario Outline: La generazione del Voucher va a buon fine quando la finalità è attiva e la variazione della stima di carico viene attivata senza necessità di approvazione
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
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA2" ha già sospeso la finalità che risulta sospesa dall'erogatore
    Given "PA2" ha già riattivato la finalità sospesa dall'erogatore
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_purpose7
  Scenario Outline: La generazione del Voucher va a buon fine quando la finalità viene sospesa e poi riattivata dal fruitore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già sospeso la finalità che risulta sospesa dal fruitore
    Given "PA1" ha già riattivato la finalità sospesa dal fruitore
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_purpose8
  Scenario Outline: La generazione del Voucher va a buon fine quando la finalità viene sospesa dall’erogatore e dal fruitore, e poi riattivata sia dall’erogatore che dal fruitore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già sospeso la finalità che risulta sospesa dal fruitore
    Given "PA2" ha già sospeso la finalità che risulta sospesa dall'erogatore
    Given "PA1" ha già riattivato la finalità sospesa dal fruitore
    Given "PA2" ha già riattivato la finalità sospesa dall'erogatore
    When l'utente richiede la generazione del voucher
    Then si ottiene la corretta generazione del voucher

  @voucher_generation_purpose9
  Scenario Outline: La generazione del Voucher fallisce quando la finalità è valida ma non assegnata al client
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già associato la finalità a quel client
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_purpose10
  Scenario Outline: La generazione del Voucher fallisce quando la finalità è valida ma non assegnata al client, e il client non ha finalità associate
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_purpose11
  Scenario Outline: La generazione del Voucher fallisce quando la finalità è archiviata
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già archiviato quella finalità
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_purpose12 @no-parallel
  Scenario Outline: La generazione del Voucher fallisce quando la finalità viene sospesa dall’erogatore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA2" ha già sospeso la finalità che risulta sospesa dall'erogatore
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_purpose13
  Scenario Outline: La generazione del Voucher fallisce quando la finalità viene sospesa dal fruitore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già sospeso la finalità che risulta sospesa dal fruitore
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_purpose14
  Scenario Outline: La generazione del Voucher fallisce quando la finalità viene sospesa dall’erogatore e dal fruitore, e poi riattivata dall’erogatore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già sospeso la finalità che risulta sospesa dal fruitore
    Given "PA2" ha già sospeso la finalità che risulta sospesa dall'erogatore
    Given "PA2" ha già riattivato la finalità sospesa dall'erogatore
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_purpose15
  Scenario Outline: La generazione del Voucher fallisce quando la finalità viene sospesa dall’erogatore e dal fruitore, e poi riattivata dal fruitore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già sospeso la finalità che risulta sospesa dal fruitore
    Given "PA2" ha già sospeso la finalità che risulta sospesa dall'erogatore
    Given "PA1" ha già riattivato la finalità sospesa dal fruitore
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_purpose16 @wait_for_fix @PIN-5318 @to_fix # Eventual consistency error
  Scenario Outline: La generazione del Voucher fallisce quando la finalità sospesa dal fruitore con una stima di carico superiore ai limiti della Versione dell’EService viene riattivata dal fruitore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "WAITING_FOR_APPROVAL" per quell'eservice
    Given "PA2" ha già approvato la richiesta di aggiornamento della stima di carico
    Given "PA1" ha già sospeso la finalità che risulta sospesa dal fruitore
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già associato la finalità a quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già riattivato la finalità sospesa dal fruitore
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine

  @voucher_generation_purpose17
  Scenario Outline: La generazione del Voucher fallisce quando la finalità non esiste
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già associato la finalità a quel client
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    Given l'utente possiede un identificativo di una purpose che non esiste
    When l'utente richiede la generazione del voucher
    Then la richiesta di generazione del Voucher non va a buon fine
