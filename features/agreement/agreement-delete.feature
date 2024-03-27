@agreement_delete
Feature: Cancellazione richiesta di fruizione
  Tutti gli utenti autorizzati possono cancellare una richiesta di fruizione in stato DRAFT o MISSING_CERTIFIED_ATTRIBUTES

  @agreement_delete1a
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato DRAFT, alla richiesta di cancellazione da parte di un utente con sufficienti permessi, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "<ente>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    When l'utente richiede una operazione di cancellazione della richiesta di fruizione
    Then si ottiene status code <risultato>

    Examples: 
      | ente    | ruolo        | risultato |
      | GSP     | admin        |       204 |
      | GSP     | api          |       403 |
      | GSP     | security     |       403 |
      | GSP     | support      |       403 |
      | GSP     | api,security |       403 |
      | PA1     | admin        |       204 |
      | PA1     | api          |       403 |
      | PA1     | security     |       403 |
      | PA1     | support      |       403 |
      | PA1     | api,security |       403 |
      | Privato | admin        |       204 |
      | Privato | api          |       403 |
      | Privato | security     |       403 |
      | Privato | support      |       403 |
      | Privato | api,security |       403 |

  @agreement_delete1b
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato MISSING_CERTIFIED_ATTRIBUTES, alla richiesta di cancellazione da parte di un utente con sufficienti permessi, va a buon fine
    Given l'utente è un "admin" di "<enteFruitore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    When l'utente richiede una operazione di cancellazione della richiesta di fruizione
    Then si ottiene status code 204

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | PA1          | PA2               | GSP           |

  @agreement_delete2a
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato PENDING, ACTIVE, SUSPENDED o ARCHIVED, alla richiesta di cancellazione da parte di un utente con sufficienti permessi, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "<tipoApprovazione>"
    Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente richiede una operazione di cancellazione della richiesta di fruizione
    Then si ottiene status code 400

    Examples: 
      | statoAgreement | tipoApprovazione |
      | PENDING        | MANUAL           |
      | ACTIVE         | AUTOMATIC        |
      | SUSPENDED      | AUTOMATIC        |
      | ARCHIVED       | AUTOMATIC        |

  @agreement_delete2b
  Scenario Outline: Per una richiesta di fruizione precedentemente creata dall’ente, la quale è in stato REJECTED, alla richiesta di cancellazione da parte di un utente con sufficienti permessi, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given un "admin" di "PA2" ha già rifiutato quella richiesta di fruizione
    When l'utente richiede una operazione di cancellazione della richiesta di fruizione
    Then si ottiene status code 400
