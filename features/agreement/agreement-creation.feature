@agreement_creation
Feature: Creazione nuova richiesta di fruizione

  @agreement_creation1
  Scenario Outline: Un utente con sufficienti permessi; il cui ente rispetta i requisiti (attributi certificati); senza altre richieste di fruizione per quell’e-service; crea una nuova richiesta di fruizione in bozza. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED. La richiesta va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" possiede un attributo certificato  # Leggere attributi certificati di ente e selezionarne uno da mettere in context
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given un "admin" di "PA2" ha già pubblicato una nuova versione per quell'e-service
    When l'utente crea una richiesta di fruizione in bozza per l'ultima versione di quell'e-service
    Then si ottiene status code <risultato>

    Examples: 
      | ente    | ruolo        | risultato |
      | GSP     | admin        |       200 |
      | GSP     | api          |       200 |
      | GSP     | security     |       200 |
      | GSP     | support      |       200 |
      | GSP     | api,security |       200 |
      | PA1     | admin        |       200 |
      | PA1     | api          |       200 |
      | PA1     | security     |       200 |
      | PA1     | support      |       200 |
      | PA1     | api,security |       200 |
      | Privato | admin        |       200 |
      | Privato | api          |       200 |
      | Privato | security     |       200 |
      | Privato | support      |       200 |
      | Privato | api,security |       200 |

  @agreement_creation2a
  Scenario Outline: Un utente con sufficienti permessi il cui ente rispetta i requisiti (attributi certificati); con altre richieste di fruizione per quell’e-service in stato REJECTED; crea una nuova richiesta di fruizione in bozza. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED. La richiesta va a buon fine.
    Given l'utente è un "admin" di "PA1"
    Given "PA1" possiede un attributo certificato
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "MANUAL"
    Given l'utente ha già inviato una richiesta di fruizione per quell'e-service
    Given un "admin" di "PA2" ha già rifiutato quella richiesta di fruizione
    Given un "admin" di "PA2" ha già pubblicato una nuova versione per quell'e-service
    When l'utente crea una richiesta di fruizione in bozza per l'ultima versione di quell'e-service
    Then si ottiene status code 200

  @agreement_creation2b
  Scenario Outline: Un utente con sufficienti permessi il cui ente rispetta i requisiti (attributi certificati); con altre richieste di fruizione per quell’e-service in stato ARCHIVED; crea una nuova richiesta di fruizione in bozza. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED. La richiesta va a buon fine.
    Given l'utente è un "admin" di "PA1"
    Given "PA1" possiede un attributo certificato
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "PA1" ha un agreement in stato "ARCHIVED" per quell'e-service
    Given un "admin" di "PA2" ha già pubblicato una nuova versione per quell'e-service
    When l'utente crea una richiesta di fruizione in bozza per l'ultima versione di quell'e-service
    Then si ottiene status code 200

  @agreement_creation3
  Scenario Outline: Un utente con sufficienti permessi; il cui ente NON rispetta i requisiti (attributi certificati); senza altre richieste di fruizione per quell’e-service; crea una nuova richiesta di fruizione in bozza. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED; l’e-service è erogato dal suo stesso ente. La richiesta va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha creato un attributo certificato senza assegnarlo all'ente  # Creazione di un attributo certificato self service e non assegnarlo
    Given un "admin" di "PA1" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    When l'utente crea una richiesta di fruizione in bozza per uno degli e-service di "PA1"
    Then si ottiene status code 200

  @agreement_creation4a
  Scenario Outline: Un utente con sufficienti permessi il cui ente rispetta i requisiti (attributi certificati); con una richiesta di fruizione per quell’e-service in stato DRAFT, PENDING, ACTIVE o SUSPENDED; crea una nuova richiesta di fruizione in bozza. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED. Ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given "PA1" possiede un attributo certificato
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "PA1" ha un agreement in stato "<statoAgreement>" per quell'e-service
    Given un "admin" di "PA2" ha già pubblicato una nuova versione per quell'e-service
    When l'utente crea una richiesta di fruizione in bozza per l'ultima versione di quell'e-service
    Then si ottiene status code 400

    Examples: 
      | statoAgreement |
      | DRAFT          |
      | PENDING        |
      | ACTIVE         |
      | SUSPENDED      |

  @agreement_creation4b
  Scenario Outline: Un utente con sufficienti permessi il cui ente rispetta i requisiti (attributi certificati); con una richiesta di fruizione per quell’e-service in stato MISSING_CERTIFIED_ATTRIBUTES; crea una nuova richiesta di fruizione in bozza. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED. Ottiene un errore.
    Given l'utente è un "admin" di "<enteFruitore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha un agreement in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    Given un "admin" di "<enteErogatore>" ha già pubblicato una nuova versione per quell'e-service
    When l'utente crea una richiesta di fruizione in bozza per l'ultima versione di quell'e-service
    Then si ottiene status code 400

    Examples:
      | enteFruitore | enteCertificatore | enteErogatore|
      | PA1          | PA2               | GSP          |

  @agreement_creation5
  Scenario Outline: Un utente con sufficienti permessi; il cui ente rispetta i requisiti (attributi certificati); senza altre richieste di fruizione per quell’e-service; crea una nuova richiesta di fruizione. L’utente crea la richiesta di fruizione per la penultima versione disponibile dell’e-service, la quale è in stato DEPRECATED. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" possiede un attributo certificato
    Given un "admin" di "PA2" ha già creato un e-service in stato "DEPRECATED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    When l'utente crea una richiesta di fruizione in bozza per la penultima versione di quell'e-service
    Then si ottiene status code 400

  @agreement_creation6
  Scenario Outline: Un utente con sufficienti permessi; il cui ente rispetta i requisiti (attributi certificati); senza altre richieste di fruizione per quell’e-service; crea una nuova richiesta di fruizione. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato SUSPENDED. Ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given "PA1" possiede un attributo certificato
    Given un "admin" di "PA2" ha già creato un e-service in stato "SUSPENDED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    When l'utente crea una richiesta di fruizione in bozza per l'ultima versione di quell'e-service
    Then si ottiene status code 400

  @agreement_creation7
  Scenario Outline: Un utente con sufficienti permessi; il cui ente NON rispetta i requisiti (attributi certificati); senza altre richieste di fruizione per quell’e-service; crea una nuova richiesta di fruizione. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED. Ottiene un errore.
    Given l'utente è un "admin" di "<enteFruitore>"
    Given "<enteCertificatore>" ha creato un attributo certificato senza assegnarlo all'ente  # Creazione di un attributo certificato self service e non assegnarlo
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    When l'utente crea una richiesta di fruizione in bozza per quell'e-service
    Then si ottiene status code 400

    Examples:
      | enteFruitore | enteCertificatore | enteErogatore|
      | PA1          | PA2               | GSP          |

  @agreement_creation8
  Scenario Outline: Un utente con sufficienti permessi; il cui ente rispetta i requisiti (attributi certificati); con un’altra richiesta di fruizione per quell’e-service, in una versione precedente all’ultima pubblicata; crea una nuova richiesta di fruizione in bozza. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED. Ottiene un errore (NB: verificare status code) - Spiega: è possibile creare una nuova bozza per effettuare l’upgrade della richiesta di fruizione; questa casistica è però gestita interamente nel flusso backend. Quando io tento di fare un upgrade di una richiesta di fruizione per la quale non rispetto tutti i requisiti, la mia richiesta di fruizione attuale rimarrà nel suo stato attuale, e ne verrà creata una nuova in bozza per l’ultima versione. Quando questa nuova richiesta sarà attiva, verrà automaticamente archiviata la precedente.

  # Cose da controllare:
  # 1 - "L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service" -> si intende che viene creato un nuovo descrittore?
  # 2 - @agreement_creation8 è una duplicazione di 4a?
  # 3 - possiamo utilizzare gli attributi certificati già presenti in ambiente o ne facciamo creare ad hoc e passarli in env? Utilizzare i self service sempre può essere un problema
  # 4 - Quali test devono coprire il caso di nuovo agreement su stesso descriptor?
  # 5 - è sempre necessario testare con gli attributi certificati o possiamo semplificare utilizzando i dichiarati?