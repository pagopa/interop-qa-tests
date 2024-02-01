@document_update

Feature: Aggiornamento del nome di un documento
  Tutti gli utenti autorizzati di enti erogatori possono modificare il nome di un documento (non di interfaccia) già caricato

  @document_update1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, e che ha almeno un documento già caricato, alla richiesta di aggiornamento del nome, l'operazione va a buon fine
     Given l'utente è un "<ruolo>" di "<ente>"
     Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato "DRAFT" e un documento già caricato
     When l'utente aggiorna il nome di quel documento
     Then si ottiene status code <risultato>

    Examples: 
      | ente               | ruolo          | risultato |
      | GSP                | admin          | 200       |
      | GSP                | api            | 200       |
      | GSP                | security       | 403       |
      | GSP                | api,security   | 200       |
      | GSP                | support        | 403       |
      | PA1                | admin          | 200       |
      | PA1                | api            | 200       |
      | PA1                | security       | 403       |
      | PA1                | api,security   | 200       |
      | PA1                | support        | 403       |

  @document_update2 @wait-for-fix
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato non DRAFT, e che ha almeno un documento già caricato, alla richiesta di aggiornamento del nome, si ottiene un errore
     Given l'utente è un "admin" di "GSP"
     Given un "admin" di "GSP" ha già creato un e-service con un descrittore in stato "<statoDescrittore>" e un documento già caricato
     When l'utente aggiorna il nome di quel documento
     Then si ottiene status code 400
   
    Examples: 
      | statoDescrittore |
      |    PUBLISHED     |
      |    SUSPENDED     |
      |    DEPRECATED    |
      |    ARCHIVED      |
