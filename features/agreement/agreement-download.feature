@agreement_download
Feature: Download attestazione richiesta di fruizione sigillata
Tutti gli utenti autorizzati possono scaricare l'attestazione di una richiesta di fruizione in stato ACTIVE, SUSPENDED o ARCHIVED.
# Verificare tempi di risposta della generazione del pdf

  @agreement_download1a
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato ACTIVE, alla richiesta di download dell'attestazione della richiesta di fruizione da parte di un utente con sufficienti permessi, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di download dell'attestazione della richiesta di fruizione
    Then si ottiene status code <risultato>

    Examples: 
      | ente    | ruolo        | risultato |
      | GSP     | admin        |       200 |
      | GSP     | api          |       403 |
      | GSP     | security     |       403 |
      | GSP     | support      |       403 |
      | GSP     | api,security |       403 |
      | PA1     | admin        |       200 |
      | PA1     | api          |       403 |
      | PA1     | security     |       403 |
      | PA1     | support      |       403 |
      | PA1     | api,security |       403 |
      | Privato | admin        |       200 |
      | Privato | api          |       403 |
      | Privato | security     |       403 |
      | Privato | support      |       403 |
      | Privato | api,security |       403 |

  @agreement_download1b
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato SUSPENDED o ARCHIVED, e che è stata in passato almeno in un momento ACTIVE, alla richiesta di download dell'attestazione della richiesta di fruizione sigillata da parte di un utente con sufficienti permessi, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente richiede una operazione di download dell'attestazione della richiesta di fruizione
    Then si ottiene status code 200

    Examples: 
      | statoAgreement |
      | SUSPENDED      |
      | ARCHIVED       |

  @agreement_download2a
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

  @agreement_download2b
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato REJECTED, alla richiesta di download dell'attestazione  della richiesta di fruizione sigillata da parte di un utente con sufficienti permessi, ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given un "admin" di "PA2" ha già rifiutato quella richiesta di fruizione
    When l'utente richiede una operazione di download dell'attestazione della richiesta di fruizione
    Then si ottiene status code 400


  @agreement_download2c
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
