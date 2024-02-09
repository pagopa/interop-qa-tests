@document_read
Feature: Lettura di un documento
  Tutti gli utenti autenticati possono recuperare un'interfaccia o un documento dai propri descrittori

  @document_read1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in qualsiasi stato (DRAFT, PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), alla richiesta di recupero di un documento precedentemente caricato da parte di un utente autorizzato, ottiene il documento
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>" e un documento già caricato
    When l'utente richiede il documento
    Then si ottiene status code <risultato>

    Examples: 
      | ente    | ruolo        | statoDescrittore | risultato |
      | GSP     | admin        | DRAFT            |       200 |
      | GSP     | api          | DRAFT            |       200 |
      | GSP     | security     | DRAFT            |       404 |
      | GSP     | api,security | DRAFT            |       200 |
      | GSP     | support      | DRAFT            |       404 |
      | GSP     | admin        | PUBLISHED        |       200 |
      | GSP     | api          | PUBLISHED        |       200 |
      | GSP     | security     | PUBLISHED        |       200 |
      | GSP     | api,security | PUBLISHED        |       200 |
      | GSP     | support      | PUBLISHED        |       200 |
      | GSP     | admin        | SUSPENDED        |       200 |
      | GSP     | api          | SUSPENDED        |       200 |
      | GSP     | security     | SUSPENDED        |       200 |
      | GSP     | api,security | SUSPENDED        |       200 |
      | GSP     | support      | SUSPENDED        |       200 |
      | GSP     | admin        | DEPRECATED       |       200 |
      | GSP     | api          | DEPRECATED       |       200 |
      | GSP     | security     | DEPRECATED       |       200 |
      | GSP     | api,security | DEPRECATED       |       200 |
      | GSP     | support      | DEPRECATED       |       200 |
      | GSP     | admin        | ARCHIVED         |       200 |
      | GSP     | api          | ARCHIVED         |       200 |
      | GSP     | security     | ARCHIVED         |       200 |
      | GSP     | api,security | ARCHIVED         |       200 |
      | GSP     | support      | ARCHIVED         |       200 |
      | PA1     | admin        | DRAFT            |       200 |
      | PA1     | api          | DRAFT            |       200 |
      | PA1     | security     | DRAFT            |       404 |
      | PA1     | api,security | DRAFT            |       200 |
      | PA1     | support      | DRAFT            |       404 |
      | PA1     | admin        | PUBLISHED        |       200 |
      | PA1     | api          | PUBLISHED        |       200 |
      | PA1     | security     | PUBLISHED        |       200 |
      | PA1     | api,security | PUBLISHED        |       200 |
      | PA1     | support      | PUBLISHED        |       200 |
      | PA1     | admin        | SUSPENDED        |       200 |
      | PA1     | api          | SUSPENDED        |       200 |
      | PA1     | security     | SUSPENDED        |       200 |
      | PA1     | api,security | SUSPENDED        |       200 |
      | PA1     | support      | SUSPENDED        |       200 |
      | PA1     | admin        | DEPRECATED       |       200 |
      | PA1     | api          | DEPRECATED       |       200 |
      | PA1     | security     | DEPRECATED       |       200 |
      | PA1     | api,security | DEPRECATED       |       200 |
      | PA1     | support      | DEPRECATED       |       200 |
      | PA1     | admin        | ARCHIVED         |       200 |
      | PA1     | api          | ARCHIVED         |       200 |
      | PA1     | security     | ARCHIVED         |       200 |
      | PA1     | api,security | ARCHIVED         |       200 |
      | PA1     | support      | ARCHIVED         |       200 |
      | Privato | admin        | DRAFT            |       200 |
      | Privato | api          | DRAFT            |       200 |
      | Privato | security     | DRAFT            |       404 |
      | Privato | api,security | DRAFT            |       200 |
      | Privato | support      | DRAFT            |       404 |
      | Privato | admin        | PUBLISHED        |       200 |
      | Privato | api          | PUBLISHED        |       200 |
      | Privato | security     | PUBLISHED        |       200 |
      | Privato | api,security | PUBLISHED        |       200 |
      | Privato | support      | PUBLISHED        |       200 |
      | Privato | admin        | SUSPENDED        |       200 |
      | Privato | api          | SUSPENDED        |       200 |
      | Privato | security     | SUSPENDED        |       200 |
      | Privato | api,security | SUSPENDED        |       200 |
      | Privato | support      | SUSPENDED        |       200 |
      | Privato | admin        | DEPRECATED       |       200 |
      | Privato | api          | DEPRECATED       |       200 |
      | Privato | security     | DEPRECATED       |       200 |
      | Privato | api,security | DEPRECATED       |       200 |
      | Privato | support      | DEPRECATED       |       200 |
      | Privato | admin        | ARCHIVED         |       200 |
      | Privato | api          | ARCHIVED         |       200 |
      | Privato | security     | ARCHIVED         |       200 |
      | Privato | api,security | ARCHIVED         |       200 |
      | Privato | support      | ARCHIVED         |       200 |
