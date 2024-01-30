@document_read

Feature: Lettura di un documento
  Tutti gli utenti autenticati di enti erogatori possono recuperare un'interfaccia o un documento dai propri descrittori

  @document_read1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in qualsiasi stato (DRAFT, PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), alla richiesta di recupero di un documento precedentemente caricato, l'operazione va a buon fine
     Given l'utente è un "<ruolo>" di "<ente>"
     Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
     Given l'utente ha già caricato un documento su quel descrittore
     When l'utente richiede il documento
     Then si ottiene status code 200
   
    Examples: 
      | ente           | ruolo | statoDescrittore |
      | GSP            | admin |    DRAFT         |
      | GSP            | admin |    PUBLISHED     |
      | GSP            | admin |    SUSPENDED     |
      | GSP            | admin |    DEPRECATED    |
      # | GSP            | admin |    ARCHIVED      |

  
  @document_read2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di recupero di un documento precedentemente caricato e poi cancellato, ottiene un errore 

     Given l'utente è un "<ruolo>" di "<ente>"
     Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "DRAFT"
     Given l'utente ha già caricato un documento su quel descrittore
     Given l'utente ha già cancellato quel documento su quel descrittore
     When l'utente richiede il documento
     Then si ottiene status code 404
   
    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |


