# PA1 è il producer
# GSP è il consumer
# il test 1 è lato producer
# il test 2 è lato consumer
@agreement_read
Feature: Lettura richiesta di fruizione

  @agreement_read1a
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato REJECTED, alla richiesta di lettura, va a buon fine
    Given l'utente è un "<ruolo>" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given un "admin" di "GSP" ha già creato e inviato una richiesta di fruizione per quell'e-service ed è in attesa di approvazione
    Given un "admin" di "PA1" ha già rifiutato quella richiesta di fruizione
    When l'utente richiede una operazione di lettura di quell'agreement
    Then si ottiene status code 200

    Examples: 
      | ruolo        |
      | admin        |
      | api          |
      | security     |
      | api,security |
      | support      |

  @agreement_read1b
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato (DRAFT, PENDING, ACTIVE, SUSPENDED, ARCHIVED), alla richiesta di lettura, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "<tipoApprovazione>"
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

  @agreement_read1c
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato MISSING_CERTIFIED_ATTRIBUTES, alla richiesta di lettura, va a buon fine
    Given l'utente è un "admin" di "<enteErogatore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    When l'utente richiede una operazione di lettura di quell'agreement
    Then si ottiene status code 200

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | GSP          | PA2               | PA1           |

  @agreement_read2a
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato REJECTED, alla richiesta di lettura, va a buon fine
    Given l'utente è un "<ruolo>" di "GSP"
    Given un "admin" di "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given un "admin" di "GSP" ha già creato e inviato una richiesta di fruizione per quell'e-service ed è in attesa di approvazione
    Given un "admin" di "PA1" ha già rifiutato quella richiesta di fruizione
    When l'utente richiede una operazione di lettura di quell'agreement
    Then si ottiene status code 200

    Examples: 
      | ruolo        |
      | admin        |
      | api          |
      | security     |
      | api,security |
      | support      |

  @agreement_read2b
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato (DRAFT, PENDING, ACTIVE, SUSPENDED, ARCHIVED), alla richiesta di lettura, va a buon fine
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "<tipoApprovazione>"
    Given "GSP" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente richiede una operazione di lettura di quell'agreement
    Then si ottiene status code 200

    Examples: 
      | statoAgreement | tipoApprovazione |
      | DRAFT          | AUTOMATIC        |
      | PENDING        | MANUAL           |
      | ACTIVE         | AUTOMATIC        |
      | SUSPENDED      | AUTOMATIC        |

  @agreement_read2c
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in  stato MISSING_CERTIFIED_ATTRIBUTES, alla richiesta di lettura, va a buon fine
    Given l'utente è un "admin" di "<enteFruitore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    When l'utente richiede una operazione di lettura di quell'agreement
    Then si ottiene status code 200

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | GSP          | PA2               | PA1           |
