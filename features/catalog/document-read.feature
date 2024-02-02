@document_read
Feature: Lettura di un documento
  Tutti gli utenti autenticati di enti erogatori possono recuperare un'interfaccia o un documento dai propri descrittori

  @document_read1 @wait_for_fix
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in qualsiasi stato (DRAFT, PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), alla richiesta di recupero di un documento precedentemente caricato da parte di un utente autorizzato, ottiene il documento
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>" e un documento già caricato
    When l'utente richiede il documento
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | statoDescrittore | risultato |
      | GSP  | admin        | DRAFT            |       200 |
      | GSP  | api          | DRAFT            |       200 |
      | GSP  | security     | DRAFT            |       400 |
      | GSP  | api,security | DRAFT            |       200 |
      | GSP  | support      | DRAFT            |       400 |
      | GSP  | admin        | PUBLISHED        |       200 |
      | GSP  | api          | PUBLISHED        |       200 |
      | GSP  | security     | PUBLISHED        |       200 |
      | GSP  | api,security | PUBLISHED        |       200 |
      | GSP  | support      | PUBLISHED        |       200 |
      | GSP  | admin        | SUSPENDED        |       200 |
      | GSP  | api          | SUSPENDED        |       200 |
      | GSP  | security     | SUSPENDED        |       200 |
      | GSP  | api,security | SUSPENDED        |       200 |
      | GSP  | support      | SUSPENDED        |       200 |
      | GSP  | admin        | DEPRECATED       |       200 |
      | GSP  | api          | DEPRECATED       |       200 |
      | GSP  | security     | DEPRECATED       |       200 |
      | GSP  | api,security | DEPRECATED       |       200 |
      | GSP  | support      | DEPRECATED       |       200 |
      | GSP  | admin        | ARCHIVED         |       200 |
      | GSP  | api          | ARCHIVED         |       200 |
      | GSP  | security     | ARCHIVED         |       200 |
      | GSP  | api,security | ARCHIVED         |       200 |
      | GSP  | support      | ARCHIVED         |       200 |
      | PA1  | admin        | DRAFT            |       200 |
      | PA1  | api          | DRAFT            |       200 |
      | PA1  | security     | DRAFT            |       400 |
      | PA1  | api,security | DRAFT            |       200 |
      | PA1  | support      | DRAFT            |       400 |
      | PA1  | admin        | PUBLISHED        |       200 |
      | PA1  | api          | PUBLISHED        |       200 |
      | PA1  | security     | PUBLISHED        |       200 |
      | PA1  | api,security | PUBLISHED        |       200 |
      | PA1  | support      | PUBLISHED        |       200 |
      | PA1  | admin        | SUSPENDED        |       200 |
      | PA1  | api          | SUSPENDED        |       200 |
      | PA1  | security     | SUSPENDED        |       200 |
      | PA1  | api,security | SUSPENDED        |       200 |
      | PA1  | support      | SUSPENDED        |       200 |
      | PA1  | admin        | DEPRECATED       |       200 |
      | PA1  | api          | DEPRECATED       |       200 |
      | PA1  | security     | DEPRECATED       |       200 |
      | PA1  | api,security | DEPRECATED       |       200 |
      | PA1  | support      | DEPRECATED       |       200 |
      | PA1  | admin        | ARCHIVED         |       200 |
      | PA1  | api          | ARCHIVED         |       200 |
      | PA1  | security     | ARCHIVED         |       200 |
      | PA1  | api,security | ARCHIVED         |       200 |
      | PA1  | support      | ARCHIVED         |       200 |

  @document_read2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di recupero di un documento precedentemente caricato e poi cancellato, ottiene un errore
    Given l'utente è un "admin" di "GSP"
    Given un "admin" di "GSP" ha già creato un e-service con un descrittore in stato "DRAFT" e un documento già caricato
    Given l'utente ha già cancellato quel documento su quel descrittore
    When l'utente richiede il documento
    Then si ottiene status code 404
