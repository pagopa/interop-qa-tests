@agreement_read
Feature: Lettura richiesta di fruizione
  Tutti gli utenti autorizzati possono leggere le richieste di fruizione che hanno creato

  @agreement_read1
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato REJECTED, alla richiesta di lettura, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given "GSP" ha già creato e inviato una richiesta di fruizione per quell'e-service ed è in attesa di approvazione
    Given "PA1" ha già rifiutato quella richiesta di fruizione
    When l'utente richiede una operazione di lettura di quell'agreement
    Then si ottiene status code 200

    Examples: 
      | ente    | ruolo        |
      | PA1     | admin        |
      | PA1     | api          |
      | PA1     | security     |
      | PA1     | api,security |
      | PA1     | support      |
      | GSP     | admin        |
      | GSP     | api          |
      | GSP     | security     |
      | GSP     | api,security |
      | GSP     | support      |
      | Privato | admin        |
      | Privato | api          |
      | Privato | security     |
      | Privato | api,security |

  @agreement_read2
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato DRAFT, PENDING, ACTIVE, SUSPENDED o ARCHIVED, alla richiesta di lettura, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "<tipoApprovazione>"
    Given "GSP" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente richiede una operazione di lettura di quell'agreement
    Then si ottiene status code 200

    Examples: 
      | statoAgreement | tipoApprovazione |
      | DRAFT          | AUTOMATIC        |
      | PENDING        | MANUAL           |
      | ACTIVE         | AUTOMATIC        |
      | SUSPENDED      | AUTOMATIC        |
      | ARCHIVED       | AUTOMATIC        |

  @agreement_read3
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato MISSING_CERTIFIED_ATTRIBUTES, alla richiesta di lettura, va a buon fine
    Given l'utente è un "admin" di "<enteFruitore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    When l'utente richiede una operazione di lettura di quell'agreement
    Then si ottiene status code 200

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | GSP          | PA2               | PA1           |

  @agreement_read4
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato ACTIVE, alla richiesta di lettura da parte di un ente nè fruitore nè erogatore, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di lettura di quell'agreement
    Then si ottiene status code 200
