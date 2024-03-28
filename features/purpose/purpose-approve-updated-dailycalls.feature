@purpose_approve_updated_dailycalls
Feature: Approvazione dell’aggiornamento di una stima di carico

  @purpose_approve_updated_dailycalls1
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE o SUSPENDED, e la cui stima di carico è stata successivamente aggiornata dal fruitore ad un valore che supera una soglia dell'erogatore portando quella versione in WAITING_FOR_APPROVAL, alla richiesta di approvazione di aggiornamento stima di carico da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato e pubblicato 1 e-service
    Given "PA2" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA2" ha già creato 1 finalità in stato "<statoFinalità>" per quell'eservice
    Given "PA2" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    When l'utente inserisce una data stimata di approvazione di quell'aggiornamento della stima di carico
    Then si ottiene status code <risultato>

    Examples: # Test sui ruoli
      | ente    | ruolo        | statoFinalità | risultato |
      | PA1     | admin        | ACTIVE        |       200 |
      | PA1     | api          | ACTIVE        |       403 |
      | PA1     | security     | ACTIVE        |       403 |
      | PA1     | api,security | ACTIVE        |       403 |
      | PA1     | support      | ACTIVE        |       403 |
      | GSP     | admin        | ACTIVE        |       200 |
      | GSP     | api          | ACTIVE        |       403 |
      | GSP     | security     | ACTIVE        |       403 |
      | GSP     | api,security | ACTIVE        |       403 |
      | GSP     | support      | ACTIVE        |       403 |


    Examples: # Test sugli stati
      | ente | ruolo | statoFinalità | risultato |
      | PA1  | admin | SUSPENDED     |       200 |

  @purpose_approve_updated_dailycalls2
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE o SUSPENDED, e la cui stima di carico è stata successivamente aggiornata dal fruitore ad un valore che supera una soglia dell'erogatore portando quella versione in WAITING_FOR_APPROVAL, alla richiesta di approvazione di aggiornamento stima di carico da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalità>" per quell'eservice
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    When l'utente inserisce una data stimata di approvazione di quell'aggiornamento della stima di carico
    Then si ottiene status code 403

    Examples: 
      | statoFinalità |
      | ACTIVE        |
      | SUSPENDED     |

  @purpose_approve_updated_dailycalls3
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, e la cui stima di carico è stata successivamente aggiornata dal fruitore ad un valore che supera una soglia dell'erogatore portando quella versione in WAITING_FOR_APPROVAL, e successivamente portata in stato ARCHIVED dal fruitore, alla richiesta di approvazione di aggiornamento stima di carico da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, ottiene un errore (NB: verificare status code). NB: a livello tecnico, nel momento in cui una finalità viene archiviata, dovrebbe essere eliminata dalla finalità la versione in WAITING_FOR_APPROVAL. Se è effettivamente questo il caso, capire assieme se vale la pena invalidare il test o aggiungere un test sull'archiviazione di una finalità per verificare questo caso
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    Given "PA1" ha già portato la finalità in stato "ARCHIVED"
    When l'utente inserisce una data stimata di approvazione di quell'aggiornamento della stima di carico
    Then si ottiene status code 400

  @purpose_approve_updated_dailycalls4 #Test non fattibile per riskAnalysisVersion
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE o SUSPENDED, e la cui stima di carico è stata successivamente aggiornata dal fruitore ad un valore che supera una soglia dell'erogatore portando quella versione in WAITING_FOR_APPROVAL, e per la quale finalità sia nel frattempo uscita una versione più recente dell’analisi del rischio da compilare, alla richiesta di approvazione di aggiornamento stima di carico da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalità>" per quell'eservice
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    When l'utente inserisce una data stimata di approvazione di quell'aggiornamento della stima di carico
    Then si ottiene status code 400

    Examples: 
      | statoFinalità |
      | ACTIVE        |
      | SUSPENDED     |
