@document_read

Feature: Lettura di un documento
  Tutti gli utenti autenticati di enti erogatori possono recuperare un'interfaccia o un documento dai propri descrittori

  @document_read1 @wait-for-fix
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in qualsiasi stato (DRAFT, PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), alla richiesta di recupero di un documento precedentemente caricato, l'operazione va a buon fine
     Given l'utente è un "<ruolo>" di "<ente>"
     Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
     Given un "admin" di "<ente>" ha già caricato un documento su quel descrittore
     When l'utente richiede il documento
     Then si ottiene status code 200
   
    Examples: 
      | ente           | ruolo        | statoDescrittore | 
      | GSP            | admin        |    DRAFT         | 
      | GSP            | api          |    DRAFT         | 
      | GSP            | security     |    DRAFT         | 
      | GSP            | api,security |    DRAFT         | 
      | GSP            | support      |    DRAFT         | 
      | GSP            | admin        |    PUBLISHED     | 
      | GSP            | api          |    PUBLISHED     | 
      | GSP            | security     |    PUBLISHED     | 
      | GSP            | api,security |    PUBLISHED     | 
      | GSP            | support      |    PUBLISHED     | 
      | GSP            | admin        |    SUSPENDED     | 
      | GSP            | api          |    SUSPENDED     | 
      | GSP            | security     |    SUSPENDED     | 
      | GSP            | api,security |    SUSPENDED     | 
      | GSP            | support      |    SUSPENDED     | 
      | GSP            | admin        |    DEPRECATED    | 
      | GSP            | api          |    DEPRECATED    | 
      | GSP            | security     |    DEPRECATED    | 
      | GSP            | api,security |    DEPRECATED    | 
      | GSP            | support      |    DEPRECATED    | 
      | GSP            | admin        |    ARCHIVED      | 
      | GSP            | api          |    ARCHIVED      | 
      | GSP            | security     |    ARCHIVED      | 
      | GSP            | api,security |    ARCHIVED      | 
      | GSP            | support      |    ARCHIVED      | 
      | PA1            | admin        |    DRAFT         | 
      | PA1            | api          |    DRAFT         | 
      | PA1            | security     |    DRAFT         | 
      | PA1            | api,security |    DRAFT         | 
      | PA1            | support      |    DRAFT         | 
      | PA1            | admin        |    PUBLISHED     | 
      | PA1            | api          |    PUBLISHED     | 
      | PA1            | security     |    PUBLISHED     | 
      | PA1            | api,security |    PUBLISHED     | 
      | PA1            | support      |    PUBLISHED     | 
      | PA1            | admin        |    SUSPENDED     | 
      | PA1            | api          |    SUSPENDED     | 
      | PA1            | security     |    SUSPENDED     | 
      | PA1            | api,security |    SUSPENDED     | 
      | PA1            | support      |    SUSPENDED     | 
      | PA1            | admin        |    DEPRECATED    | 
      | PA1            | api          |    DEPRECATED    | 
      | PA1            | security     |    DEPRECATED    | 
      | PA1            | api,security |    DEPRECATED    | 
      | PA1            | support      |    DEPRECATED    | 
      | PA1            | admin        |    ARCHIVED      | 
      | PA1            | api          |    ARCHIVED      | 
      | PA1            | security     |    ARCHIVED      | 
      | PA1            | api,security |    ARCHIVED      | 
      | PA1            | support      |    ARCHIVED      | 
  
  @document_read2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di recupero di un documento precedentemente caricato e poi cancellato, ottiene un errore 

     Given l'utente è un "admin" di "GSP"
     Given un "admin" di "GSP" ha già creato un e-service con un descrittore in stato "DRAFT"
     Given un "admin" di "GSP" ha già caricato un documento su quel descrittore
     Given l'utente ha già cancellato quel documento su quel descrittore
     When l'utente richiede il documento
     Then si ottiene status code 404
