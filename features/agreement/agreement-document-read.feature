@agreement_document_read
Feature: Lettura di un documento allegato alla richiesta di fruizione
Tutti gli utenti autorizzati possono leggere un documento allegato alla richiesta di fruizione

  @agreement_document_read1
  Scenario Outline: Un utente con sufficienti permessi, per una richiesta di fruizione precedentemente creata, la quale è in stato DRAFT, relativa a un e-service pubblicato dallo stesso ente, alla richiesta di lettura di un documento allegato, la richiesta va a buon fine.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato e pubblicato 1 e-service
    Given un "<ruolo>" di "<ente>" ha già creato una richiesta di fruizione in stato DRAFT
    Given l'utente ha già caricato un documento allegato a quella richiesta di fruizione
    When l'utente richiede una operazione di lettura del documento allegato a quella richiesta di fruizione
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
      | PA2     | admin        |       200 |
      | PA2     | api          |       403 |
      | PA2     | security     |       403 |
      | PA2     | support      |       403 |
      | PA2     | api,security |       403 |      
      | Privato | admin        |       200 |
      | Privato | api          |       403 |
      | Privato | security     |       403 |
      | Privato | support      |       403 |
      | Privato | api,security |       403 |


#   @agreement_document_read2a
#   Scenario Outline: Un utente con sufficienti permessi, per una richiesta di fruizione precedentemente creata, la quale è in stato PENDING, ACTIVE, SUSPENDED, ARCHIVED, alla richiesta di lettura di un documento allegato, la richiesta va a buon fine.
#     Given l'utente è un "admin" di "PA1"
#     Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "<tipoApprovazione>"
#     Given un "<ruolo>" di "<ente>" ha già creato una richiesta di fruizione in stato DRAFT
#     Given l'utente ha già caricato un documento allegato a quella richiesta di fruizione
#     Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
#     When l'utente richiede una operazione di lettura del documento allegato a quella richiesta di fruizione
#     Then si ottiene status code 200

#     Examples: 
#       | statoAgreement | tipoApprovazione |
#       | DRAFT          |   AUTOMATIC      |
#       | PENDING        |   MANUAL         |
#       | ACTIVE         |   AUTOMATIC      |
#       | SUSPENDED      |   AUTOMATIC      |
#       | ARCHIVED       |   AUTOMATIC      |


#   @agreement_document_read2b
#   Scenario Outline: Un utente con sufficienti permessi, per una richiesta di fruizione precedentemente creata, la quale è in stato MISSING_CERTIFIED_ATTRIBUTES, carica un documento associando un nome al documento (prettyName). Ottiene un errore.
#     Given l'utente è un "admin" di "<enteFruitore>"
#     Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
#     Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
#     Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
#     Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
#     Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
#     When l'utente carica un documento allegato a quella richiesta di fruizione
#     Then si ottiene status code 400

#     Examples:
#       | enteFruitore | enteCertificatore | enteErogatore|
#       | PA1          | PA2               | GSP          |
