@client_purpose_add
Feature: Associazione purpose al client
  Tutti gli utenti autenticati possono associare una purpose ad un 

  @client_purpose_add1
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client di tipo CONSUMER e attivato una finalità che si trova in stato ACTIVE, richiede l’associazione del client alla finalità. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given <ente> ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given <ente> ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given <ente> ha già creato 1 client "CONSUMER"
    When l'utente richiede l'associazione della finalità al client
    Then si ottiene status code <statusCode>

    Examples:
      | ente | ruolo        | statusCode |
      | GSP  | admin        |        200 |
      | GSP  | api          |        403 |
      | GSP  | security     |        200 |
      | GSP  | support      |        200 |
      | GSP  | api,security |        200 |
      | PA1  | admin        |        200 |
      | PA1  | api          |        403 |
      | PA1  | security     |        200 |
      | PA1  | support      |        200 |
      | PA1  | api,security |        200 |

  @client_purpose_add2
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client di tipo CONSUMER e attivato una finalità che si trova in stato NON ACTIVE, richiede l'associazione del client alla finalità. Ottiene un errore. Chiarimento: è possibile modificare l’associazione/disassociazione dei client ad una finalità solo se questa è attiva
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    When l'utente richiede l'associazione della finalità al client
    Then si ottiene status code 400

    Examples:
      | statoFinalita        |
      | DRAFT                |
      | SUSPENDED            |
      | WAITING_FOR_APPROVAL |
      | ARCHIVED             |

  @client_purpose_add2b
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client di tipo CONSUMER e attivato una finalità che si trova in stato NON ACTIVE, richiede l'associazione del client alla finalità. Ottiene un errore. Chiarimento: è possibile modificare l’associazione/disassociazione dei client ad una finalità solo se questa è attiva
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "WAITING_FOR_APPROVAL" per quell'eservice
    Given "PA2" ha già rifiutato l'aggiornamento della stima di carico per quella finalità
    Given "PA1" ha già creato 1 client "CONSUMER"
    When l'utente richiede l'associazione della finalità al client
    Then si ottiene status code 400

  @client_purpose_add3
  Scenario Outline: Un utente con sufficienti permessi (admin) non associato all'ente che ha creato il client di tipo CONSUMER e attivato una finalità che si trova in stato ACTIVE, richiede l'associazione del client alla finalità. Ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "GSP" ha già creato 1 client "CONSUMER"
    When l'utente richiede l'associazione della finalità al client
    Then si ottiene status code 400

  @client_purpose_add4
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client di tipo API e attivato una finalità che si trova in stato ACTIVE, richiede l’associazione del client alla finalità. Ottiene un errore (NB: verificare status code). Chiarimento: non è possibile associare client destinati al consumo dell'API Interop ad una finalità 
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "API"
    When l'utente richiede l'associazione della finalità al client
    Then si ottiene status code 400
