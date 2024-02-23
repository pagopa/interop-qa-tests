@agreement_creation
Feature: Creazione nuova richiesta di fruizione

  @agreement_creation1
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente rispetta i requisiti (attributi certificati); senza altre richieste di fruizione per quell’e-service; crea una nuova richiesta di fruizione in bozza. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED. La richiesta va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" possiede un attributo certificato
    Given un "admin" di "PA2" ha già creato un e-service in stato PUBLISHED che richiede quell'attributo certificato con approvazione "AUTOMATIC"
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
    Given un "admin" di "PA2" ha già creato un e-service in stato PUBLISHED che richiede quell'attributo certificato con approvazione "MANUAL"
    Given l'utente ha già inviato una richiesta di fruizione per quell'e-service
    Given un "admin" di "PA2" ha già rifiutato quella richiesta di fruizione
    Given un "admin" di "PA2" ha già pubblicato una nuova versione per quell'e-service
    When l'utente crea una richiesta di fruizione in bozza per l'ultima versione di quell'e-service
    Then si ottiene status code 200

  @agreement_creation2b
  Scenario Outline: Un utente con sufficienti permessi il cui ente rispetta i requisiti (attributi certificati); con altre richieste di fruizione per quell’e-service in stato ARCHIVED; crea una nuova richiesta di fruizione in bozza. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED. La richiesta va a buon fine.
    Given l'utente è un "admin" di "PA1"
    Given "PA1" possiede un attributo certificato
    Given un "admin" di "PA2" ha già creato un e-service in stato PUBLISHED che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "PA1" ha un agreement in stato "ARCHIVED" per quell'e-service
    Given un "admin" di "PA2" ha già pubblicato una nuova versione per quell'e-service
    When l'utente crea una richiesta di fruizione in bozza per l'ultima versione di quell'e-service
    Then si ottiene status code 200

  @agreement_creation3
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente NON rispetta i requisiti (attributi certificati); senza altre richieste di fruizione per quell’e-service; crea una nuova richiesta di fruizione in bozza. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED; l’e-service è erogato dal suo stesso ente. La richiesta va a buon fine
    Given l'utente è un "admin" di "GSP" #TODO come gestire il requisito degli attributi certificati?
    Given un "admin" di "GSP" ha già creato 3 e-services in stato PUBLISHED
    When l'utente crea una richiesta di fruizione in bozza per uno degli e-service di "PA2"
    Then si ottiene status code 200

  @agreement_creation4
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente rispetta i requisiti (attributi certificati); con una richiesta di fruizione già in stato DRAFT, PENDING, ACTIVE, SUSPENDED, o MISSING_CERTIFIED_ATTRIBUTES per lo stesso e-service (anche se in versione diversa); crea una nuova richiesta di fruizione.  L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED. Ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "GSP" ha già creato 3 e-services in stato PUBLISHED
    Given "GSP" ha un agreement in stato "<statoFruizione>" per l'e-service numero 1 di "PA1"
    Given un "admin" di "GSP" ha già pubblicato una nuova versione per quell'e-service
    When l'utente crea una richiesta di fruizione per una nuova versione di quell'e-service di "PA2"
    Then si ottiene status code 400

  @agreement_creation5
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente rispetta i requisiti (attributi certificati); senza altre richieste di fruizione per quell’e-service; crea una nuova richiesta di fruizione. L’utente crea la richiesta di fruizione per la penultima versione disponibile dell’e-service, la quale è in stato DEPRECATED. Ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato 3 e-services in stato PUBLISHED
    Given un "admin" di "PA1" ha già pubblicato una nuova versione per 3 di questi e-service
    When l'utente crea una richiesta di fruizione per la penultima versione di uno di quegli e-service
    Then si ottiene status code 400

  @agreement_creation6
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente rispetta i requisiti (attributi certificati); senza altre richieste di fruizione per quell’e-service; crea una nuova richiesta di fruizione. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato SUSPENDED. Ottiene un errore (NB: verificare status code) - Spiega: non posso creare una richiesta di fruizione per un e-service attualmente sospeso.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service con un descrittore in stato "SUSPENDED"
    When l'utente crea una richiesta di fruizione per quell'e-service
    Then si ottiene status code 400

  @agreement_creation7
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente NON rispetta i requisiti (attributi certificati); senza altre richieste di fruizione per quell’e-service; crea una nuova richiesta di fruizione. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED. Ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "GSP" #TODO come gestire il requisito degli attributi certificati?
    Given un "admin" di "PA2" ha già creato 1 e-services in stato PUBLISHED
    When l'utente crea una richiesta di fruizione per quell'e-service
    Then si ottiene status code 400

  @agreement_creation8
  Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente rispetta i requisiti (attributi certificati); con un’altra richiesta di fruizione per quell’e-service, in una versione precedente all’ultima pubblicata; crea una nuova richiesta di fruizione in bozza. L’utente crea la richiesta di fruizione per l’ultima versione disponibile dell’e-service, la quale è in stato PUBLISHED. Ottiene un errore (NB: verificare status code) - Spiega: è possibile creare una nuova bozza per effettuare l’upgrade della richiesta di fruizione; questa casistica è però gestita interamente nel flusso backend. Quando io tento di fare un upgrade di una richiesta di fruizione per la quale non rispetto tutti i requisiti, la mia richiesta di fruizione attuale rimarrà nel suo stato attuale, e ne verrà creata una nuova in bozza per l’ultima versione. Quando questa nuova richiesta sarà attiva, verrà automaticamente archiviata la precedente.
