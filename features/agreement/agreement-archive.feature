@agreement_archive
Feature: Archiviazione richiesta di fruizione
Tutti gli utenti autorizzati possono archiviare una richiesta di fruizione in stato ACTIVE o SUSPENDED

  @agreement_archive1a
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE, alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di archiviazione della richiesta di fruizione
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

  @agreement_archive1b
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato SUSPENDED, alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "PA1" ha una richiesta di fruizione in stato "SUSPENDED" per quell'e-service
    When l'utente richiede una operazione di archiviazione della richiesta di fruizione
    Then si ottiene status code 204

  @agreement_archive2
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE o SUSPENDED, alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, ottiene un errore
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente richiede una operazione di archiviazione della richiesta di fruizione
    Then si ottiene status code 403

    Examples: 
      | statoAgreement |
      | ACTIVE         |
      | SUSPENDED      |

  @agreement_archive3a @wait_for_fix
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato DRAFT o ARCHIVED, alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente richiede una operazione di archiviazione della richiesta di fruizione
    Then si ottiene status code 400

    Examples: 
      | statoAgreement |
      | DRAFT          |
      | ARCHIVED       |

  @agreement_archive3b @wait_for_fix
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato PENDING alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    When l'utente richiede una operazione di archiviazione della richiesta di fruizione
    Then si ottiene status code 400

  @agreement_archive3c @wait_for_fix
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato REJECTED alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given un "admin" di "PA2" ha già rifiutato quella richiesta di fruizione
    When l'utente richiede una operazione di archiviazione della richiesta di fruizione
    Then si ottiene status code 400

  @agreement_archive3d @wait_for_fix
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato MISSING_CERTIFIED_ATTRIBUTES alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "<enteFruitore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    When l'utente richiede una operazione di archiviazione della richiesta di fruizione
    Then si ottiene status code 400

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | PA1          | PA2               | GSP           |
