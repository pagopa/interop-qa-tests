@purpose_archive
Feature: Archiviazione di una finalità


# Abbiamo dei dubbi su :"Per una finalità precedentemente creata da un fruitore e attivata da un erogatore". Con questa frase si vuole indicare che:
# 1) L'ente fruitore crea una finalità superando le stime di carico definite dall'e-service
# 2) A quel punto la finalità va in "WAITING_FOR_APPROVAL" e quindi conseguentemente  l'erogatore dovrà approvarla
# ?


  @purpose_archive1a
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE, alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "ente" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "<ente>" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    When l'utente archivia quella finalità
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

  @purpose_archive1b
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato SUSPENDED, alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "<ente>" ha già creato 1 finalità in stato "ACTIVE" per quell'eservice
    When l'utente archivia quella finalità
    Then si ottiene status code 200

  @purpose_archive2
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE o SUSPENDED, con una versione di finalità successiva in stato WAITING_FOR_APPROVAL alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "<ente>" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    Given "PA1" ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service
    When l'utente archivia quella finalità
    Then si ottiene status code 200

    Examples: 
      | statoFinalita |
      | ACTIVE        |
      | SUSPENDED     |

  @purpose_archive3
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE o SUSPENDED, alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "<ente>" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente archivia quella finalità
    Then si ottiene status code 400

    Examples: 
      | statoFinalita |
      | ACTIVE        |
      | SUSPENDED     |

  @purpose_archive4
  Scenario Outline: Per una finalità precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato REJECTED, WAITING_FOR_APPROVAL, PENDING, DRAFT o ARCHIVED, alla richiesta di archiviazione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, ottiene un errore (NB: verificare status code)
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given un "admin" di "<ente>" ha già creato 1 finalità in stato "<statoFinalita>" per quell'eservice
    When l'utente archivia quella finalità
    Then si ottiene status code 400

    Examples: 
      | statoFinalita        |
      | REJECTED             |
      | WAITING_FOR_APPROVAL |
      | PENDING              |
      | DRAFT                |
      | ARCHIVED             |
