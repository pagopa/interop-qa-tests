@purpose-consumer-listing
Feature: Listing delle finalità lato erogatore

  @purpose-consumer-listing1
  Scenario Outline: A fronte di 20 finalità in db, restituisce solo i primi 12 risultati (scopo del test è verificare il corretto funzionamento del parametro limit)
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given l'utente ha già creato 20 finalità in stato "DRAFT" per quell'eservice
    When l'utente richiede una operazione di listing degli delle finalità alle prime 12 finalità
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | risultato |
      | PA1  | admin        |       200 |
      | PA1  | api          |       403 |
      | PA1  | security     |       403 |
      | PA1  | api,security |       403 |
      | PA1  | support      |       403 |
      | GSP  | admin        |       200 |
      | GSP  | api          |       403 |
      | GSP  | security     |       403 |
      | GSP  | api,security |       403 |
      | GSP  | support      |       403 |

  @purpose-consumer-listing2
  Scenario Outline: A fronte di 15 finalità in db e una richiesta di offset 12, restituisce solo 3 risultati (scopo del test è verificare il corretto funzionamento del parametro offset)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given l'utente ha già creato 20 finalità in stato "DRAFT" per quell'eservice
    When l'utente richiede una operazione di listing degli delle finalità alle prime 12 finalità
    Then si ottiene status code <risultato>


  @purpose-consumer-listing3
  Scenario Outline: Per una finalità precedentemente creata da un fruitore, la quale prima versione è in qualsiasi stato (DRAFT, (WAITING_FOR_APPROVAL, ACTIVE, SUSPENDED, ARCHIVED), alla richiesta di lettura da parte di un ente che non è né l’erogatore, né il fruitore, ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato una finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente richiede la lettura della finalità
    Then si ottiene status code 400

    Examples: 
      | statoFinalita        |
      | DRAFT                |
      | ACTIVE               |
      | SUSPENDED            |
      | WAITING_FOR_APPROVAL |
      | ARCHIVED             |