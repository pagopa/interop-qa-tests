@purpose_clone
Feature: Clonazione di una finalità
  Tutti gli utenti admin di enti fruitori possono clonare una propria finalità

  @purpose_clone1
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato ACTIVE, per una versione di e-service, il quale ha mode = RECEIVE, clona una finalità. La richiesta va a buon fine.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given un "admin" di "PA2" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "PA2" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "PA2" ha già pubblicato quella versione di e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "<ente>" ha già creato una finalità in stato "<statoFinalità>" per quell'eservice associando quell'analisi del rischio creata dall'erogatore
    When l'utente richiede una operazione di clonazione della finalità
    Then si ottiene status code <risultato>

    Examples: # Test sui ruoli
      | ente    | ruolo        | statoFinalità | risultato |
      | PA1     | admin        | ACTIVE        |       200 |
      | PA1     | api          | ACTIVE        |       403 |
      | PA1     | security     | ACTIVE        |       403 |
      | PA1     | api,security | ACTIVE        |       403 |
      | PA1     | support      | ACTIVE        |       403 |
      | GSP     | admin        | ACTIVE        |       200 |
      | GSP     | api          | ACTIVE        |       403 |
      | GSP     | security     | ACTIVE        |       403 |
      | GSP     | api,security | ACTIVE        |       403 |
      | GSP     | support      | ACTIVE        |       403 |
      | Privato | admin        | ACTIVE        |       200 |
      | Privato | api          | ACTIVE        |       403 |
      | Privato | security     | ACTIVE        |       403 |
      | Privato | api,security | ACTIVE        |       403 |
      | Privato | support      | ACTIVE        |       403 |

    Examples: # Test sugli stati
      | ente | ruolo | statoFinalità        | risultato |
      | PA1  | admin | WAITING_FOR_APPROVAL |       200 |
      | PA1  | admin | SUSPENDED            |       200 |

  @purpose_clone2 @wait_for_fix @IMN-399
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato DRAFT, o ARCHIVED per una versione di e-service, il quale ha mode = RECEIVE, clona una finalità. Ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given un "admin" di "PA2" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "PA2" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "PA2" ha già pubblicato quella versione di e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato una finalità in stato "<statoFinalita>" per quell'eservice associando quell'analisi del rischio creata dall'erogatore
    When l'utente richiede una operazione di clonazione della finalità
    Then si ottiene status code 409

    Examples: 
      | statoFinalita |
      | DRAFT         |
      | ARCHIVED      |

  @purpose_clone3
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una finalità in stato WAITING_FOR_APPROVAL, ACTIVE, o SUSPENDED per una versione di e-service, il quale ha mode = DELIVER, clona una finalità. La richiesta va a buon fine. Spiega: visto che ci sono problemi legati all’analisi del rischio in erogazione inversa, non è possibile clonare una finalità che faccia riferimento a un e-service in erogazione inversa. (Che vuol dire "spiega" sembra che tutti gli altri test siano implementati seguendo questa logica)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente richiede una operazione di clonazione della finalità
    Then si ottiene status code 200

    Examples: 
      | statoFinalita        |
      | ACTIVE               |
      | WAITING_FOR_APPROVAL |
      | SUSPENDED            |
