@client_purpose_add
Feature: Associazione finalità al client
  Tutti gli utenti autenticati possono associare una finalità ad un client
  
  @client_purpose_add1a
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client di tipo CONSUMER e attivato una finalità che si trova in stato ACTIVE o SUSPENDED, richiede l’associazione del client alla finalità. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "<ente>" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    Given "<ente>" ha già creato 1 client "CONSUMER"
    When l'utente richiede l'associazione della finalità al client
    Then si ottiene status code <statusCode>

    Examples:
      | ente | ruolo        | statoFinalita | statusCode |
      | GSP  | admin        | ACTIVE        |        204 |
      | GSP  | api          | ACTIVE        |        403 |
      | GSP  | security     | ACTIVE        |        403 |
      | GSP  | support      | ACTIVE        |        403 |
      | GSP  | api,security | ACTIVE        |        403 |
      | PA1  | admin        | ACTIVE        |        204 |
      | PA1  | api          | ACTIVE        |        403 |
      | PA1  | security     | ACTIVE        |        403 |
      | PA1  | support      | ACTIVE        |        403 |
      | PA1  | api,security | ACTIVE        |        403 |

    Examples:
      | ente | ruolo | statoFinalita        | statusCode |
      | PA1  | admin | SUSPENDED            |        204 |
      | PA1  | admin | DRAFT                |        400 |
      | GSP  | admin | WAITING_FOR_APPROVAL |        400 |
      | PA1  | admin | ARCHIVED             |        400 |

  @client_purpose_add1b
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client di tipo CONSUMER e attivato una finalità che si trova in stato NON ACTIVE, richiede l'associazione del client alla finalità. Ottiene un errore. Chiarimento: è possibile modificare l’associazione/disassociazione dei client ad una finalità solo se questa è attiva
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "WAITING_FOR_APPROVAL" per quell'eservice
    Given "PA2" ha già rifiutato l'aggiornamento della stima di carico per quella finalità
    Given "PA1" ha già creato 1 client "CONSUMER"
    When l'utente richiede l'associazione della finalità al client
    Then si ottiene status code 400

  @client_purpose_add2
  Scenario Outline: Un utente con sufficienti permessi (admin) non associato all'ente che ha creato il client di tipo CONSUMER e attivato una finalità che si trova in stato ACTIVE, richiede l'associazione del client alla finalità. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "GSP" ha già creato 1 client "CONSUMER"
    When l'utente richiede l'associazione della finalità al client
    Then si ottiene status code 403

  @client_purpose_add3 @wait_for_fix @PIN-4954
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client di tipo API e attivato una finalità che si trova in stato ACTIVE, richiede l’associazione del client alla finalità. Ottiene un errore. Chiarimento: non è possibile associare client destinati al consumo dell'API Interop ad una finalità
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "API"
    When l'utente richiede l'associazione della finalità al client
    Then si ottiene status code 403
