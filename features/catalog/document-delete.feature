@document_delete

Feature: Cancellazione di un documento
  Tutti gli utenti autenticati di enti erogatori possono cancellare un'interfaccia o un documento dai propri descrittori

  @document_delete1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di cancellazione di un documento precedentemente caricato, l'operazione va a buon fine
     Given l'utente è un "<ruolo>" di "<ente>"
     Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "DRAFT"
     Given l'utente ha già caricato un documento su quel descrittore
     When l'utente cancella il documento
     Then si ottiene status code 204
   

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |


  @document_delete2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), alla richiesta di cancellazione di un documento precedentemente caricato, ottiene un errore
  # (NB: status code restituito: BadRequest attualmente (18/01) questo controllo non viene effettuato e la cancellazione va a buon fine)

     Given l'utente è un "<ruolo>" di "<ente>"
     Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
     Given l'utente ha già caricato un documento su quel descrittore
     When l'utente cancella il documento
     Then si ottiene status code 204
     # Then si ottiene status code 400 # TODO: waiting for fix to BFF to return status code 400
   
    Examples: 
      | ente           | ruolo | statoDescrittore |
      | GSP            | admin |    PUBLISHED     |
      | GSP            | admin |    SUSPENDED     |
      | GSP            | admin |    DEPRECATED    |
      # | GSP            | admin |    ARCHIVED      |
