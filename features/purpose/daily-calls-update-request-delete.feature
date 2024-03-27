@daily_calls_update_request_delete
Feature: 
Cancellazione di una richiesta di aggiornamento di una stima di carico
Tutti gli utenti autorizzati possono cancellare una richiesta di aggiornamento di una stima di carico 

  @daily_calls_update_request_delete1
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE o SUSPENDED, e la cui stima di carico è stata successivamente aggiornata dal fruitore ad un valore che supera una soglia dell'erogatore portando quella versione in WAITING_FOR_APPROVAL, alla richiesta di cancellazione di aggiornamento stima di carico da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "<ente>" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "<ente>" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    When l'utente richiede la cancellazione della richiesta di aggiornamento della stima di carico
    Then si ottiene status code 200

    Examples: 
      | ente    | ruolo        | risultato |
      | PA1     | admin        |       200 |
      | PA1     | api          |       403 |
      | PA1     | security     |       403 |
      | PA1     | api,security |       403 |
      | PA1     | support      |       403 |
      | GSP     | admin        |       200 |
      | GSP     | api          |       403 |
      | GSP     | security     |       403 |
      | GSP     | api,security |       403 |
      | GSP     | support      |       403 |
      | Privato | admin        |       200 |
      | Privato | api          |       403 |
      | Privato | security     |       403 |
      | Privato | api,security |       403 |
      | Privato | support      |       403 |

  @daily_calls_update_request_delete1b
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato  SUSPENDED, e la cui stima di carico è stata successivamente aggiornata dal fruitore ad un valore che supera una soglia dell'erogatore portando quella versione in WAITING_FOR_APPROVAL, alla richiesta di cancellazione di aggiornamento stima di carico da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "SUSPENDED" per quell'eservice
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    When l'utente richiede la cancellazione della richiesta di aggiornamento della stima di carico
    Then si ottiene status code 200

  @daily_calls_update_request_delete2
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, e la cui stima di carico è stata successivamente aggiornata dal fruitore ad un valore che supera una soglia dell'erogatore portando quella versione in WAITING_FOR_APPROVAL, e successivamente portata in stato ARCHIVED dal fruitore, alla richiesta di cancellazione di aggiornamento stima di carico da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, ottiene un errore (NB: verificare status code). NB: a livello tecnico, nel momento in cui una finalità viene archiviata, dovrebbe essere eliminata dalla finalità la versione in WAITING_FOR_APPROVAL. Se è effettivamente questo il caso, capire assieme se vale la pena invalidare il test o aggiungere un test sull'archiviazione di una finalità per verificare questo caso. Vedi test analogo nella sezione “Approvazione dell’aggiornamento di una stima di carico
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "SUSPENDED" per quell'eservice
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    Given "PA1" ha già portato la finalità in stato ARCHIVED
    When l'utente richiede la cancellazione della richiesta di aggiornamento della stima di carico
    Then si ottiene status code 400

  @daily_calls_update_request_delete3
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE o SUSPENDED, e la cui stima di carico è stata successivamente aggiornata dal fruitore ad un valore che supera una soglia dell'erogatore portando quella versione in WAITING_FOR_APPROVAL, alla richiesta di cancellazione di aggiornamento stima di carico da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, ottiene un errore
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    When l'utente richiede la cancellazione della richiesta di aggiornamento della stima di carico
    Then si ottiene status code 400

        Examples: 
      | statoFinalita |
      | ACTIVE        |
      | SUSPENDED     |

