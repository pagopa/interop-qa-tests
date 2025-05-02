@purpose_creation_deliver
Feature: Creazione finalità per e-service in erogazione diretta
  Tutti gli utenti autorizzati possono creare una nuova finalità per un e-service in erogazione diretta.

  @purpose_creation_deliver1
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati. La richiesta va a buon fine.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
    Then si ottiene status code <risultato>

    Examples: 
      | ente    | ruolo        | risultato |
      | PA1     | admin        |       200 |
      | PA1     | api          |       403 |
      | PA1     | security     |       403 |
      | PA1     | api,security |       403 |
      | PA1     | support      |       403 |
      | GSP     | admin        |       200 |
      | GSP     | api          |       403 |
      | GSP     | security     |       403 |
      | GSP     | api,security |       403 |
      | GSP     | support      |       403 |
      | Privato | admin        |       200 |
      | Privato | api          |       403 |
      | Privato | security     |       403 |
      | Privato | api,security |       403 |
      | Privato | support      |       403 |

  @purpose_creation_deliver2
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, e una finalità già in stato DRAFT per lo stesso e-service, crea una nuova finalità con tutti i campi richiesti correttamente formattati. La richiesta va a buon fine.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "DRAFT" per quell'eservice
    When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
    Then si ottiene status code 200

  @purpose_creation_deliver3
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, la quale è in stato SUSPENDED, crea una nuova finalità con tutti i campi richiesti correttamente formattati. La richiesta va a buon fine.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA2" ha già sospeso quell'e-service
    When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
    Then si ottiene status code 200

  @purpose_creation_deliver4a
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato NON ACTIVE (DRAFT, PENDING, SUSPENDED, ARCHIVED) per un e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "<tipoApprovazione>"
    Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
    Then si ottiene status code 400

    Examples: 
      | statoAgreement | tipoApprovazione |
      | DRAFT          | AUTOMATIC        |
      | PENDING        | MANUAL           |
      | SUSPENDED      | AUTOMATIC        |
      | ARCHIVED       | AUTOMATIC        |

  @purpose_creation_deliver4b
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato MISSING_CERTIFIED_ATTRIBUTES per un e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore.
    Given l'utente è un "admin" di "<enteFruitore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
    Then si ottiene status code 400

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | GSP          | PA2               | PA1           |

  @purpose_creation_deliver4c
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato REJECTED per un e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given "PA2" ha già rifiutato quella richiesta di fruizione
    When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
    Then si ottiene status code 400

  @purpose_creation_deliver5
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente NON ha già una richiesta di fruizione per una versione di e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
    Then si ottiene status code 400

  @purpose_creation_deliver6
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati, il campo isFreeOfCharge valorizzato a true e il campo freeOfChargeReason non compilato. Ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati, in modalità gratuita senza specificare una ragione
    Then si ottiene status code 400

  @purpose_creation_deliver7 @wait_for_fix @PIN-5236 @to_fix # expected 200 - actual 400
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati con una riskAnalysis parzialmente compilata ma formattata correttamente (ossia sono compilati solo alcuni campi, ma quei campi sono compilati correttamente). La richiesta va a buon fine.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati, con un'analisi del rischio parzialmente compilata ma formattata correttamente
    Then si ottiene status code 200

  @purpose_creation_deliver8
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati con una riskAnalysis parzialmente compilata, che è formattata correttamente, ma la quale versione della riskAnalysis non è l’ultima disponibile per quella tipologia di ente (es. la versione corrente è la v2, viene compilata la v1). Ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati, con un'analisi del rischio parzialmente compilata, formattata correttamente, ma con un template datato
    Then si ottiene status code 400

  @purpose_creation_deliver9
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati e la salva; crea una seconda finalità che ha lo stesso nome della precedente, prova a salvarla. Ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato una finalità per quell'e-service con tutti i campi richiesti correttamente formattati
    When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati e lo stesso nome della precedente
    Then si ottiene status code 409

  @purpose_creation_deliver10
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente A ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati e la salva. Un ente B ha già una richiesta di fruizione in stato ACTIVE per lo stesso e-service; crea una finalità con lo stesso nome della precedente e la salva. L’operazione va a buon fine.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già creato una finalità per quell'e-service con tutti i campi richiesti correttamente formattati
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati e lo stesso nome della precedente
    Then si ottiene status code 200
