@eservice_description_update
Feature: Aggiornamento della descrizione di un e-service
  Tutti gli utenti autorizzati di enti erogatori possono aggiornare la descrizione un proprio e-service attivo

  @eservice_description_update1
  Scenario Outline: A fronte di una richiesta aggiornamento della descrizione di un e-service da parte di un utente autorizzato dell’ente che lo eroga, va a buon fine solo per un e-service con descrittori in stato PUBLISHED, SUSPENDED e DEPRECATED
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
    When l'utente aggiorna la descrizione di quell'e-service
    Then si ottiene status code <risultato>

    Examples:
      | ente | ruolo        | statoDescrittore | risultato |
      | PA1  | admin        | PUBLISHED        |       200 |
      | PA1  | api          | PUBLISHED        |       200 |
      | PA1  | security     | PUBLISHED        |       403 |
      | PA1  | api,security | PUBLISHED        |       200 |
      | PA1  | support      | PUBLISHED        |       403 |
      | GSP  | admin        | PUBLISHED        |       200 |
      | GSP  | api          | PUBLISHED        |       200 |
      | GSP  | security     | PUBLISHED        |       403 |
      | GSP  | api,security | PUBLISHED        |       200 |
      | GSP  | support      | PUBLISHED        |       403 |

    Examples: # ARCHIVED non viene testato in quanto non è possibile avere un eservice con un singolo descrittore in stato ARCHIVED
      | ente | ruolo | statoDescrittore | risultato |
      | PA1  | admin | SUSPENDED        |       200 |
      | PA1  | admin | DEPRECATED       |       200 |
      | PA1  | admin | DRAFT            |       409 |

  @eservice_description_update2
  Scenario Outline: A fronte di una richiesta aggiornamento della descrizione di un e-service da parte di un utente autorizzato dell’ente che lo eroga, per un e-service senza descrittori, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service senza descrittore
    When l'utente aggiorna la descrizione di quell'e-service
    Then si ottiene status code 409
