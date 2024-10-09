@document_update
Feature: Aggiornamento del nome di un documento
  Tutti gli utenti autorizzati di enti erogatori possono modificare il nome di un documento (non di interfaccia) già caricato

  @document_update1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in uno dei sequenti stati: (PUBLISHED, DRAFT, DEPRECATED, SUSPENDED), e che ha almeno un documento già caricato, alla richiesta di aggiornamento del nome, l'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>" e un documento già caricato
    When l'utente aggiorna il nome di quel documento
    Then si ottiene status code <risultato>

    Examples:
      | ente | ruolo        | statoDescrittore | risultato |
      | GSP  | admin        | DRAFT            |       200 |
      | GSP  | api          | DRAFT            |       200 |
      | GSP  | security     | DRAFT            |       403 |
      | GSP  | api,security | DRAFT            |       200 |
      | GSP  | support      | DRAFT            |       403 |
      | PA1  | admin        | DRAFT            |       200 |
      | PA1  | api          | DRAFT            |       200 |
      | PA1  | security     | DRAFT            |       403 |
      | PA1  | api,security | DRAFT            |       200 |
      | PA1  | support      | DRAFT            |       403 |

    Examples: # Test sugli stati
      | ente | ruolo | statoDescrittore | risultato |
      | GSP  | admin | PUBLISHED        |       200 |
      | GSP  | admin | SUSPENDED        |       200 |
      | GSP  | admin | DEPRECATED       |       200 |

  @document_update2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato ARCHIVED, e che ha almeno un documento già caricato, alla richiesta di aggiornamento del nome, si ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "ARCHIVED" e un documento già caricato
    When l'utente aggiorna il nome di quel documento
    Then si ottiene status code 400

  @document_update3
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, e che ha almeno due documenti già caricati, alla richiesta di aggiornamento del nome di uno di quelli, se il nome aggiornato è già in uso da uno degli altri documenti si ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "DRAFT"
    Given "PA1" ha già caricato due documenti con nome "test 1" e "test 2" in quel descrittore
    When l'utente modifica il nome del secondo documento in "test 1"
    Then si ottiene status code 409
