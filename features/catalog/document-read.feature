@document_read
Feature: Lettura di un documento
  Tutti gli utenti autenticati possono recuperare un'interfaccia o un documento dai propri descrittori

  @document_read1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di recupero di un documento precedentemente caricato da parte di un utente autorizzato (api, admin, support dell’ente erogatore di quell’e-service), l'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato un e-service con un descrittore in stato "DRAFT" e un documento già caricato
    When l'utente richiede il documento
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | risultato |
      | GSP  | admin        |       200 |
      | GSP  | api          |       200 |
      | GSP  | security     |       404 |
      | GSP  | api,security |       200 |
      | GSP  | support      |       200 |
      | PA1  | admin        |       200 |
      | PA1  | api          |       200 |
      | PA1  | security     |       404 |
      | PA1  | api,security |       200 |
      | PA1  | support      |       200 |

  @document_read2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), alla richiesta di recupero di un documento precedentemente caricato da parte di un utente autenticato (qualunque livello di permesso di qualunque ente), l'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA1" ha già creato un e-service con un descrittore in stato "<statoDescrittore>" e un documento già caricato
    When l'utente richiede il documento
    Then si ottiene status code 200

    Examples: 
      | ente    | ruolo        | statoDescrittore |
      | GSP     | admin        | PUBLISHED        |
      | GSP     | api          | PUBLISHED        |
      | GSP     | security     | PUBLISHED        |
      | GSP     | api,security | PUBLISHED        |
      | GSP     | support      | PUBLISHED        |
      | GSP     | admin        | SUSPENDED        |
      | GSP     | api          | SUSPENDED        |
      | GSP     | security     | SUSPENDED        |
      | GSP     | api,security | SUSPENDED        |
      | GSP     | support      | SUSPENDED        |
      | GSP     | admin        | DEPRECATED       |
      | GSP     | api          | DEPRECATED       |
      | GSP     | security     | DEPRECATED       |
      | GSP     | api,security | DEPRECATED       |
      | GSP     | support      | DEPRECATED       |
      | GSP     | admin        | ARCHIVED         |
      | GSP     | api          | ARCHIVED         |
      | GSP     | security     | ARCHIVED         |
      | GSP     | api,security | ARCHIVED         |
      | GSP     | support      | ARCHIVED         |
      | PA1     | admin        | PUBLISHED        |
      | PA1     | api          | PUBLISHED        |
      | PA1     | security     | PUBLISHED        |
      | PA1     | api,security | PUBLISHED        |
      | PA1     | support      | PUBLISHED        |
      | PA1     | admin        | SUSPENDED        |
      | PA1     | api          | SUSPENDED        |
      | PA1     | security     | SUSPENDED        |
      | PA1     | api,security | SUSPENDED        |
      | PA1     | support      | SUSPENDED        |
      | PA1     | admin        | DEPRECATED       |
      | PA1     | api          | DEPRECATED       |
      | PA1     | security     | DEPRECATED       |
      | PA1     | api,security | DEPRECATED       |
      | PA1     | support      | DEPRECATED       |
      | PA1     | admin        | ARCHIVED         |
      | PA1     | api          | ARCHIVED         |
      | PA1     | security     | ARCHIVED         |
      | PA1     | api,security | ARCHIVED         |
      | PA1     | support      | ARCHIVED         |
      | Privato | admin        | PUBLISHED        |
      | Privato | api          | PUBLISHED        |
      | Privato | security     | PUBLISHED        |
      | Privato | api,security | PUBLISHED        |
      | Privato | support      | PUBLISHED        |
      | Privato | admin        | SUSPENDED        |
      | Privato | api          | SUSPENDED        |
      | Privato | security     | SUSPENDED        |
      | Privato | api,security | SUSPENDED        |
      | Privato | support      | SUSPENDED        |
      | Privato | admin        | DEPRECATED       |
      | Privato | api          | DEPRECATED       |
      | Privato | security     | DEPRECATED       |
      | Privato | api,security | DEPRECATED       |
      | Privato | support      | DEPRECATED       |
      | Privato | admin        | ARCHIVED         |
      | Privato | api          | ARCHIVED         |
      | Privato | security     | ARCHIVED         |
      | Privato | api,security | ARCHIVED         |
      | Privato | support      | ARCHIVED         |
