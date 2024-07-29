@client_purpose_remove
Feature: Rimozione purpose dal client
  Tutti gli utenti autenticati possono disassociare una finalità da un client 

  @client_purpose_remove1a
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client di tipo CONSUMER ed associato il client ad una finalità che si trova in stato ACTIVE, SUSPENDED o WAITING_FOR_APPROVAL, richiede la disassociazione del client dalla finalità. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "<ente>" ha già creato 1 finalità in stato "<statoFinalità>" per quell'eservice
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già associato la finalità a quel client
    When l'utente richiede la disassociazione della finalità dal client
    Then si ottiene status code <statusCode>
    
    # la finalità in stato WAITING_FOR_APPROVAL non può essere associata al client quindi non viene testata

    Examples:
      | ente | ruolo        | statoFinalità | statusCode |
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
      | ente | ruolo | statoFinalità | statusCode |
      | PA1  | admin | SUSPENDED     |        204 |

  @client_purpose_remove1b
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client di tipo CONSUMER ed associato il client ad una finalità che si trova in stato ARCHIVED richiede la disassociazione del client dalla finalità. L'operazione va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già associato la finalità a quel client
    Given "PA1" ha già archiviato quella finalità
    When l'utente richiede la disassociazione della finalità dal client
    Then si ottiene status code 204

  @client_purpose_remove2a @wait_for_fix @PIN-4953
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client ed associato il client di tipo CONSUMER ad una finalità che si trova in stato DRAFT, richiede la disassociazione del client dalla finalità. Ottiene un errore. Chiarimento: è possibile modificare l’associazione/disassociazione dei client ad una finalità solo se questa è attiva
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "DRAFT" per quell'eservice
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già associato la finalità a quel client
    When l'utente richiede la disassociazione della finalità dal client
    Then si ottiene status code 400

  @client_purpose_remove2b @wait_for_fix @PIN-4953
  Scenario Outline: Un utente con sufficienti permessi (admin) dell'ente che ha creato il client ed associato il client di tipo CONSUMER ad una finalità che si trova in stato REJECTED, richiede la disassociazione del client dalla finalità. Ottiene un errore. Chiarimento: è possibile modificare l’associazione/disassociazione dei client ad una finalità solo se questa è attiva
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "PA1" ha già creato 1 finalità in stato "WAITING_FOR_APPROVAL" per quell'eservice
    Given "PA2" ha già rifiutato l'aggiornamento della stima di carico per quella finalità
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già associato la finalità a quel client
    When l'utente richiede la disassociazione della finalità dal client
    Then si ottiene status code 400

  @client_purpose_remove3
  Scenario Outline: Un utente con sufficienti permessi (admin) non associato all'ente che ha creato il client di tipo CONSUMER ed associato il client ad una finalità che si trova in stato ACTIVE, richiede la disassociazione del client dalla finalità. Ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "GSP" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "GSP" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "GSP" ha già creato 1 client "CONSUMER"
    Given "GSP" ha già associato la finalità a quel client
    When l'utente richiede la disassociazione della finalità dal client
    Then si ottiene status code 403
