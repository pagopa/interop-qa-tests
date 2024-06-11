@document_delete
Feature: Cancellazione di un documento
  Tutti gli utenti autorizzati di enti erogatori possono cancellare un documento dai propri descrittori

  @document_delete1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in uno dei sequenti stati: (PUBLISHED, DRAFT, DEPRECATED, SUSPENDED), alla richiesta di cancellazione di un documento precedentemente caricato, l'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>" e un documento già caricato
    When l'utente cancella quel documento
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | risultato | statoDescrittore |
      | GSP  | admin        |       204 | DRAFT            |
      | GSP  | api          |       204 | DRAFT            |
      | GSP  | security     |       403 | DRAFT            |
      | GSP  | api,security |       204 | DRAFT            |
      | GSP  | support      |       403 | DRAFT            |
      | PA1  | admin        |       204 | DRAFT            |
      | PA1  | api          |       204 | DRAFT            |
      | PA1  | security     |       403 | DRAFT            |
      | PA1  | api,security |       204 | DRAFT            |
      | PA1  | support      |       403 | DRAFT            |

    Examples: # Test sugli stati
      | ente | ruolo        | risultato | statoDescrittore |
      | GSP  | admin        |       204 | PUBLISHED        |
      | GSP  | admin        |       204 | SUSPENDED        |
      | GSP  | admin        |       204 | DEPRECATED       |

  @document_delete2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato ARCHIVED alla richiesta di cancellazione di un documento precedentemente caricato, si ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "ARCHIVED" e un documento già caricato
    When l'utente cancella quel documento
    Then si ottiene status code 400