@agreement_clone
Feature: Clonazione di una richiesta di fruizione.
  Tutti gli utenti autorizzati possono clonare una richiesta di fruizione in stato REJECTED

  @agreement_clone1
  Scenario Outline: Un utente con sufficienti permessi, clona una richiesta di fruizione in stato REJECTED. La richiesta va a buon fine.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given "<ente>" ha già creato e inviato una richiesta di fruizione per quell'e-service ed è in attesa di approvazione
    Given "PA2" ha già rifiutato quella richiesta di fruizione
    When l'utente clona quella richiesta di fruizione
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

  @agreement_clone2a
  Scenario Outline: Un utente con sufficienti permessi, clona una richiesta di fruizione in stato DRAFT, PENDING, ACTIVE, SUSPENDED, ARCHIVED. Ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "<tipoApprovazione>"
    Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente clona quella richiesta di fruizione
    Then si ottiene status code 400

    Examples: 
      | statoAgreement | tipoApprovazione |
      | DRAFT          | AUTOMATIC        |
      | PENDING        | MANUAL           |
      | ACTIVE         | AUTOMATIC        |
      | SUSPENDED      | AUTOMATIC        |
      | ARCHIVED       | AUTOMATIC        |

  @agreement_clone2b
  Scenario Outline: Un utente con sufficienti permessi, clona una richiesta di fruizione in stato MISSING_CERTIFIED_ATTRIBUTES. Ottiene un errore.
    Given l'utente è un "admin" di "<enteFruitore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    When l'utente clona quella richiesta di fruizione
    Then si ottiene status code 400

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | PA1          | PA2               | GSP           |
