@purpose_creation_receive
Feature: Creazione finalità per e-service in erogazione inversa
  Tutti gli utenti admin di enti PA o GSP possono creare una nuova finalità per un e-service in erogazione inversa.

  @purpose_creation_receive1
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = RECEIVE, crea una nuova finalità con tutti i campi richiesti correttamente formattati. La richiesta va a buon fine.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA1" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given un "admin" di "PA1" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "PA1" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "PA1" ha già pubblicato quella versione di e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente crea una nuova finalità con tutti i campi richiesti correttamente formattati per quell'e-service associando quella analisi del rischio creata dall'erogatore
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

  @purpose_creation_receive2
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = RECEIVE, e una finalità già in stato DRAFT per lo stesso e-service, crea una nuova finalità con tutti i campi richiesti correttamente formattati. La richiesta va a buon fine. Spiega: è possibile creare più finalità sulla stessa richiesta di fruizione
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "GSP" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given un "admin" di "GSP" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "GSP" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "GSP" ha già pubblicato quella versione di e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato una finalità in stato "DRAFT" per quell'eservice associando quell'analisi del rischio creata dall'erogatore
    When l'utente crea una nuova finalità con tutti i campi richiesti correttamente formattati per quell'e-service associando quella analisi del rischio creata dall'erogatore
    Then si ottiene status code 200

  @purpose_creation_receive3
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = RECEIVE, la quale è in stato SUSPENDED, crea una nuova finalità con tutti i campi richiesti correttamente formattati. La richiesta va a buon fine. Spiega: è possibile creare una finalità anche se l’e-service è sospeso
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "GSP" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given un "admin" di "GSP" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "GSP" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "GSP" ha già pubblicato quella versione di e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "GSP" ha già sospeso quell'e-service
    When l'utente crea una nuova finalità con tutti i campi richiesti correttamente formattati per quell'e-service associando quella analisi del rischio creata dall'erogatore
    Then si ottiene status code 200

  @purpose_creation_receive4a
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato NON ACTIVE (DRAFT, PENDING, SUSPENDED o ARCHIVED) per un e-service, il quale ha mode = RECEIVE, crea una nuova finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore (NB: verificare status code).
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "GSP" ha già creato un e-service in stato DRAFT in modalità RECEIVE con approvazione "<tipoApprovazione>"
    Given un "admin" di "GSP" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "GSP" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "GSP" ha già pubblicato quella versione di e-service
    Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente crea una nuova finalità con tutti i campi richiesti correttamente formattati per quell'e-service associando quella analisi del rischio creata dall'erogatore
    Then si ottiene status code 400

    Examples: 
      | statoAgreement | tipoApprovazione |
      | DRAFT          | AUTOMATIC        |
      | PENDING        | MANUAL           |
      | SUSPENDED      | AUTOMATIC        |
      | ARCHIVED       | AUTOMATIC        |

  @purpose_creation_receive4b
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato MISSING_CERTIFIED_ATTRIBUTES per un e-service, il quale ha mode = RECEIVE, crea una nuova finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore (NB: verificare status code).
    Given l'utente è un "admin" di "<enteFruitore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in modalità RECEIVE in stato DRAFT che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given un "admin" di "<enteErogatore>" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "<enteErogatore>" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "<enteErogatore>" ha già pubblicato quella versione di e-service
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    When l'utente crea una nuova finalità con tutti i campi richiesti correttamente formattati per quell'e-service associando quella analisi del rischio creata dall'erogatore
    Then si ottiene status code 400

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | PA1          | PA2               | GSP           |

  @purpose_creation_receive4c
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato REJECTED per un e-service, il quale ha mode = RECEIVE, crea una nuova finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore (NB: verificare status code).
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in stato DRAFT in modalità RECEIVE con approvazione "MANUAL"
    Given un "admin" di "PA2" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "PA2" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "PA2" ha già pubblicato quella versione di e-service
    Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given un "admin" di "PA2" ha già rifiutato quella richiesta di fruizione
    When l'utente crea una nuova finalità con tutti i campi richiesti correttamente formattati per quell'e-service associando quella analisi del rischio creata dall'erogatore
    Then si ottiene status code 400

  @purpose_creation_receive5
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente NON ha già una richiesta di fruizione per una versione di e-service, il quale ha mode = RECEIVE, crea una nuova finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore (NB: verificare status code).
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given un "admin" di "PA1" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "PA1" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "PA1" ha già pubblicato quella versione di e-service
    When l'utente crea una nuova finalità con tutti i campi richiesti correttamente formattati per quell'e-service associando quella analisi del rischio creata dall'erogatore
    Then si ottiene status code 400

  @purpose_creation_receive6
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = RECEIVE, crea una nuova finalità con tutti i campi richiesti correttamente formattati, il campo isFreeOfCharge valorizzato a true e il campo freeOfChargeReason non compilato. Ottiene un errore (NB: verificare status code). Spiega: non è possibile creare una finalità ad uso gratuito senza specificare qual è la ragione
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given un "admin" di "PA1" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "PA1" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "PA1" ha già pubblicato quella versione di e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente crea una nuova finalità per quell'e-service associando quella analisi del rischio creata dall'erogatore con tutti i campi richiesti correttamente formattati, in modalità gratuita senza specificare una ragione
    Then si ottiene status code 400

  @purpose_creation_receive7
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = RECEIVE, crea una nuova finalità con tutti i campi richiesti correttamente formattati ma senza riskAnalysisId. Ottiene un errore (NB: verificare status code).
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given un "admin" di "PA1" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "PA1" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "PA1" ha già pubblicato quella versione di e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati senza passare l'identificativo dell'analisi del rischio
    Then si ottiene status code 400

  @purpose_creation_receive8
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = RECEIVE, crea una nuova finalità con tutti i campi richiesti correttamente formattati, con in aggiunta un riskAnalysisId diverso da uno di quelli delle riskAnalysis create dall'erogatore. Ottiene un errore (NB: verificare status code).
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA1" ha già creato un e-service in modalità "RECEIVE" con un descrittore in stato "DRAFT"
    Given un "admin" di "PA1" ha già creato un'analisi del rischio per quell'e-service
    Given un "admin" di "PA1" ha già caricato un'interfaccia per quel descrittore
    Given un "admin" di "PA1" ha già pubblicato quella versione di e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente crea una nuova finalità per quell'e-service associando una analisi del rischio diversa da quelle create dall'erogatore
    Then si ottiene status code 400
