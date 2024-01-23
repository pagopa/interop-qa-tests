@document_update

Feature: Aggiornamento del nome di un documento
  Tutti gli utenti autenticati di enti erogatori possono modificare il nome di un documento (non di interfaccia) già caricato

  @document_update1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, e che ha almeno un documento già caricato, alla richiesta di aggiornamento del nome, l'operazione va a buon fine
     Given l'utente è un "<ruolo>" di "<ente>"
     Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "DRAFT"
     Given l'utente ha già caricato un documento su quel descrittore
     When l'utente aggiorna il nome di quel documento
     Then si ottiene status code 200
   

    Examples: 
      | ente           | ruolo |
      | GSP            | admin |
      | PA1            | admin |

  @document_update2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato non DRAFT, e che ha almeno un documento già caricato, alla richiesta di aggiornamento del nome, si ottiene un errore
     Given l'utente è un "<ruolo>" di "<ente>"
     Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
     Given l'utente ha già caricato un documento su quel descrittore
     When l'utente aggiorna il nome di quel documento
     Then si ottiene status code 400
   
   
    Examples: 
      | ente           | ruolo | statoDescrittore |
      | GSP            | admin |    PUBLISHED     |
      | GSP            | admin |    SUSPENDED     |
      | GSP            | admin |    DEPRECATED    |
      # | GSP            | admin |    ARCHIVED      |
