@agreement_download
Feature: Download attestazione richiesta di fruizione sigillata
  Tutti gli utenti autorizzati possono scaricare l'attestazione di una richiesta di fruizione in stato ACTIVE, SUSPENDED o ARCHIVED.

  @agreement_download1a
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato ACTIVE, alla richiesta di download dell'attestazione della richiesta di fruizione da parte di un utente con sufficienti permessi, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given l'attestazione di quella richiesta di fruizione è già stata generata
    When l'utente richiede una operazione di download dell'attestazione della richiesta di fruizione
    Then si ottiene status code 200

    Examples: # Test sui ruoli
      | ente    | ruolo        | statoAgreement |
      | GSP     | admin        | ACTIVE         |
      | GSP     | api          | ACTIVE         |
      | GSP     | security     | ACTIVE         |
      | GSP     | support      | ACTIVE         |
      | GSP     | api,security | ACTIVE         |
      | PA1     | admin        | ACTIVE         |
      | PA1     | api          | ACTIVE         |
      | PA1     | security     | ACTIVE         |
      | PA1     | support      | ACTIVE         |
      | PA1     | api,security | ACTIVE         |
      | Privato | admin        | ACTIVE         |
      | Privato | api          | ACTIVE         |
      | Privato | security     | ACTIVE         |
      | Privato | support      | ACTIVE         |
      | Privato | api,security | ACTIVE         |

    Examples: # Test sugli stati
      | ente | ruolo | statoAgreement |
      | PA1  | admin | SUSPENDED      |
      | PA1  | admin | ARCHIVED       |

  @agreement_download2a @wait_for_fix @IMN-305
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato DRAFT, PENDING, alla richiesta di download dell'attestazione  della richiesta di fruizione sigillata da parte di un utente con sufficienti permessi, ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "<tipoApprovazione>"
    Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente richiede una operazione di download dell'attestazione della richiesta di fruizione
    Then si ottiene status code 400

    Examples: 
      | statoAgreement | tipoApprovazione |
      | DRAFT          | AUTOMATIC        |
      | PENDING        | MANUAL           |

  @agreement_download2b @wait_for_fix @IMN-305
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato REJECTED, alla richiesta di download dell'attestazione  della richiesta di fruizione sigillata da parte di un utente con sufficienti permessi, ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given un "admin" di "PA2" ha già rifiutato quella richiesta di fruizione
    When l'utente richiede una operazione di download dell'attestazione della richiesta di fruizione
    Then si ottiene status code 400

  @agreement_download2c @wait_for_fix @IMN-305
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato MISSING_CERTIFIED_ATTRIBUTES, alla richiesta di download dell'attestazione  della richiesta di fruizione sigillata da parte di un utente con sufficienti permessi, ottiene un errore.
    Given l'utente è un "admin" di "<enteFruitore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    When l'utente richiede una operazione di download dell'attestazione della richiesta di fruizione
    Then si ottiene status code 400

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | PA1          | PA2               | GSP           |
