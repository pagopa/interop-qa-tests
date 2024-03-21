@purpose-clone
Feature: Clonazione di una finalità (fruitore)

  @purpose-clone-1a
  Scenario Outline: 
Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato ACTIVE, per una versione di e-service, il quale ha mode = RECEIVE, clona una finalità. La richiesta va a buon fine.

    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given un "admin" di "PA2" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "PA2" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "PA2" ha già pubblicato quella versione di e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "<ruolo>" di "<ente>" ha già creato 1 finalità in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di clonazione della finalità
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | risultato |
      | PA1  | admin        |       200 |
      | PA1  | api          |       403 |
      | PA1  | security     |       403 |
      | PA1  | api,security |       403 |
      | PA1  | support      |       403 |
      | GSP  | admin        |       200 |
      | GSP  | api          |       403 |
      | GSP  | security     |       403 |
      | GSP  | api,security |       403 |
      | GSP  | support      |       403 |

  @purpose-clone-1b
  Scenario Outline: 
Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato WAITING_FOR_APPROVAL o SUSPENDED per una versione di e-service, il quale ha mode = RECEIVE, clona una finalità. La richiesta va a buon fine.

    Given l'utente è un "admin di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given un "admin" di "PA2" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "PA2" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "PA2" ha già pubblicato quella versione di e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'e-service
    When l'utente richiede una operazione di clonazione della finalità
    Then si ottiene status code 200

    Examples: 
      | statoFinalita        |
      | WAITING_FOR_APPROVAL |
      | SUSPENDED            |

  @purpose-clone-2
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato DRAFT, o ARCHIVED per una versione di e-service, il quale ha mode = RECEIVE, clona una finalità. Ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given un "admin" di "PA2" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "PA2" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "PA2" ha già pubblicato quella versione di e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'e-service
    When l'utente richiede una operazione di clonazione della finalità
    Then si ottiene status code 400

    Examples: 
      | statoFinalita |
      | DRAFT         |
      | ARCHIVED      |

  @purpose-clone-3
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato WAITING_FOR_APPROVAL, ACTIVE, o SUSPENDED per una versione di e-service, il quale ha mode = DELIVER, clona una finalità. La richiesta va a buon fine. Spiega: visto che ci sono problemi legati all’analisi del rischio in erogazione inversa, non è possibile clonare una finalità che faccia riferimento a un e-service in erogazione inversa. (Che vuol dire "spiega" sembra che tutti gli altri test siano implementati seguendo questa logica)
    Given l'utente è un "admin di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato un e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'e-service
    When l'utente richiede una operazione di clonazione della finalità
    Then si ottiene status code 400

    Examples: 
      | statoFinalita        |
      | ACTIVE               |
      | WAITING_FOR_APPROVAL |
      | SUSPENDED            |
