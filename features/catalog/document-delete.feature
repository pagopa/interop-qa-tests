@document_delete
Feature: Cancellazione di un documento
  Tutti gli utenti autorizzati di enti erogatori possono cancellare un documento dai propri descrittori

  @document_delete1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di cancellazione di un documento precedentemente caricato, l'operazione va a buon fine
     Given l'utente è un "<ruolo>" di "<ente>"
     Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato "DRAFT"
     Given un "admin" di "<ente>" ha già caricato un documento su quel descrittore
     When l'utente cancella quel documento
     Then si ottiene status code <risultato>

    Examples: 
      | ente  | ruolo          | risultato |
      | GSP   | admin          | 204       |
      | GSP   | api            | 204       |
      | GSP   | security       | 403       |
      | GSP   | api,security   | 204       |
      | GSP   | support        | 403       |
      | PA1   | admin          | 204       |
      | PA1   | api            | 204       |
      | PA1   | security       | 403       |
      | PA1   | api,security   | 204       |
      | PA1   | support        | 403       |

  @document_delete2 @wait-for-fix
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), alla richiesta di cancellazione di un documento precedentemente caricato, si ottiene un errore

     Given l'utente è un "admin" di "GSP"
     Given un "admin" di "GSP" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
     Given un "admin" di "GSP" ha già caricato un documento su quel descrittore
     When l'utente cancella quel documento
     Then si ottiene status code 400
   
    Examples: 
      | statoDescrittore |
      |    PUBLISHED     |
      |    SUSPENDED     |
      |    DEPRECATED    |
      |    ARCHIVED      |