@agreement_update
Feature: Aggiornamento di una richiesta di fruizione in bozza
  Tutti gli utenti autorizzati possono aggiornare una propria richiesta di fruizione in bozza con un messaggio

  @agreement_update1
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato DRAFT, alla richiesta di aggiornamento della bozza da parte di un utente con sufficienti permessi dell’ente fruitore con un messaggio per l’erogatore (consumerNotes) aggiornato, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "<ente>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    When l'utente richiede una operazione di aggiornamento di quella richiesta di fruizione con messaggio
    Then si ottiene status code <risultato>

    Examples: 
      | ente    | ruolo        | risultato |
      | PA1     | admin        |       200 |
      | PA1     | api          |       403 |
      | PA1     | security     |       403 |
      | PA1     | support      |       403 |
      | PA1     | api,security |       403 |
      | GSP     | admin        |       200 |
      | GSP     | api          |       403 |
      | GSP     | security     |       403 |
      | GSP     | support      |       403 |
      | GSP     | api,security |       403 |
      | Privato | admin        |       200 |
      | Privato | api          |       403 |
      | Privato | security     |       403 |
      | Privato | support      |       403 |

  @agreement_update2a
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato REJECTED, alla richiesta di aggiornamento della bozza da parte di un utente con sufficienti permessi dell’ente fruitore con un messaggio per l’erogatore (consumerNotes) aggiornato, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "GSP" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given "PA1" ha già creato e inviato una richiesta di fruizione per quell'e-service ed è in attesa di approvazione
    Given "GSP" ha già rifiutato quella richiesta di fruizione
    When l'utente richiede una operazione di aggiornamento di quella richiesta di fruizione con messaggio
    Then si ottiene status code 400

  @agreement_update2b
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato MISSING_CERTIFIED_ATTRIBUTES, alla richiesta di aggiornamento della bozza da parte di un utente con sufficienti permessi dell’ente fruitore con un messaggio per l’erogatore (consumerNotes) aggiornato, ottiene un errore
    Given l'utente è un "admin" di "<enteFruitore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    When l'utente richiede una operazione di aggiornamento di quella richiesta di fruizione con messaggio
    Then si ottiene status code 400

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | PA1          | PA2               | GSP           |

  @agreement_update2c
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato NON DRAFT (PENDING, ACTIVE, SUSPENDED, ARCHIVED), alla richiesta di aggiornamento della bozza da parte di un utente con sufficienti permessi dell’ente fruitore con un messaggio per l’erogatore (consumerNotes) aggiornato, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "<tipoApprovazione>"
    Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente richiede una operazione di aggiornamento di quella richiesta di fruizione con messaggio
    Then si ottiene status code 400

    Examples: 
      | statoAgreement | tipoApprovazione |
      | PENDING        | MANUAL           |
      | ACTIVE         | AUTOMATIC        |
      | SUSPENDED      | AUTOMATIC        |
      | ARCHIVED       | AUTOMATIC        |
