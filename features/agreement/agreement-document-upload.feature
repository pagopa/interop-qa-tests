@agreement_document_upload
Feature: Caricamento di un documento allegato alla richiesta di fruizione
Tutti gli utenti autorizzati possono caricare un documento allegato alla richiesta di fruizione in stato DRAFT

  @agreement_document_upload1
  Scenario Outline: Un utente con sufficienti permessi, per una richiesta di fruizione precedentemente creata, la quale è in stato DRAFT, carica un documento associando un nome al documento (prettyName). La richiesta va a buon fine.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given "<ente>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    When l'utente carica un documento allegato a quella richiesta di fruizione
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

  @agreement_document_upload2a @wait_for_fix @IMN-311
  Scenario Outline: Un utente con sufficienti permessi, per una richiesta di fruizione precedentemente creata, la quale è in stato PENDING, ACTIVE, SUSPENDED, ARCHIVED, carica un documento associando un nome al documento (prettyName). Ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "<tipoApprovazione>"
    Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente carica un documento allegato a quella richiesta di fruizione
    Then si ottiene status code 403

    Examples: 
      | statoAgreement | tipoApprovazione |
      | PENDING        | MANUAL           |
      | ACTIVE         | AUTOMATIC        |
      | SUSPENDED      | AUTOMATIC        |
      | ARCHIVED       | AUTOMATIC        |

  @agreement_document_upload2b
  Scenario Outline: Un utente con sufficienti permessi, per una richiesta di fruizione precedentemente creata, la quale è in stato MISSING_CERTIFIED_ATTRIBUTES, carica un documento associando un nome al documento (prettyName). Ottiene un errore.
    Given l'utente è un "admin" di "<enteFruitore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    When l'utente carica un documento allegato a quella richiesta di fruizione
    Then si ottiene status code 403

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | PA1          | PA2               | GSP           |
