@purpose_activation
Feature: Attivazione e riattivazione di una finalità

  @purpose_activation1
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è stata successivamente portata in stato SUSPENDED, alla richiesta di riattivazione da parte di un utente con sufficienti permessi (admin) dell’ente che ha sospeso la finalità, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "<ente>" ha già creato 1 finalità in stato "SUSPENDED" per quell'eservice
    When l'utente riattiva la finalità per quell'e-service
    # Implementare in modo da poter scrivere sia "riattiva" che "attiva"
    Then si ottiene status code <risultato>

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

  @purpose_activation2
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è stata successivamente portata in stato SUSPENDED, alla richiesta di riattivazione da parte di un utente con sufficienti permessi (admin) dell’ente opposto a quello che ha sospeso la finalità (es. se sospesa dall’erogatore, è il fruitore), va a buon fine ma la finalità non cambia stato. NB: verificare se va effettivamente a buon fine per idempotenza o se dà errore
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "SUSPENDED" per quell'eservice
    When l'utente riattiva la finalità per quell'e-service
    Then si ottiene status code 200

  @purpose_activation3
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, alla richiesta di riattivazione da parte di un utente con sufficienti permessi (admin), va a buon fine. NB: verificare se va effettivamente a buon fine per idempotenza o se dà errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    When l'utente riattiva la finalità per quell'e-service
    Then si ottiene status code 200

  @purpose_activation4
  Scenario Outline: Per una finalità precedentemente creata da un fruitore, la quale è sopra soglia ed è passata da DRAFT a WAITING_FOR_APPROVAL, alla richiesta di attivazione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, va a buon fine
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "WAITING_FOR_APPROVAL" per quell'eservice
    When l'utente attiva la finalità per quell'e-service
    Then si ottiene status code 200

  @purpose_activation5
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è stata successivamente portata in stato SUSPENDED dall’erogatore; per la quale versione di e-service sia stata successivamente superata una delle soglie di carico; alla richiesta di riattivazione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, va a buon fine e la finalità passa in stato ACTIVE. Spiega: se è l’erogatore a riattivare una finalità sospesa, anche se questa è sopra soglia, passa in stato attivo; si intende che l’erogatore, riattivandola, approvi implicitamente che la finalità possa contribuire al carico sull’e-service.
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    Given "PA2" ha già portato la finalità in stato "SUSPENDED"
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    When l'utente riattiva la finalità per quell'e-service
    Then si ottiene status code 200

  @purpose_activation6
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è stata successivamente portata in stato SUSPENDED dal fruitore; per la quale versione di e-service sia stata successivamente superata una delle soglie di carico; alla richiesta di riattivazione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, va a buon fine e la finalità passa in stato WAITING_FOR_APPROVAL. Spiega: se è il fruitore a riattivare una finalità sospesa, se questa è sopra soglia, passa in stato WAITING_FOR_APPROVAL; si intende che il fruitore, riattivandola, debba vedersi approvato il fatto che la finalità superi una o più delle soglie previste dall’erogatore. Questo perché, mentre la finalità era sospesa, è possibile che siano state attivate altre finalità, che abbiano contribuito ad aumentare il carico sull’e-service dell’erogatore.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "SUSPENDED" per quell'eservice
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    When l'utente riattiva la finalità per quell'e-service
    Then si ottiene status code 200 e si verifica che la finalità sia in stato WAITING_FOR_APPROVAL
    # Controllare la waitingForApprovalVersion

  @purpose_activation7
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e che è in stato DRAFT, REJECTED o ARCHIVED, alla richiesta di attivazione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA2"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "PA1" ha già creato 1 finalità in stato "<statoFinalità" per quell'eservice
    When l'utente riattiva la finalità per quell'e-service
    Then si ottiene status code 400

    Examples: 
      | statoFinalità |
      | DRAFT         |
      | REJECTED      |
      | ARCHIVED      |