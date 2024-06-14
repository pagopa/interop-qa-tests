@client_keys_listing
Feature: Listing chiavi client
  Tutti gli utenti admin, security o support possono leggere la lista delle chiavi di un client a cui sono associati

  @client_keys_listing1
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente è membro del client; richiede l’elenco delle chiavi caricate per il client. L’operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "<ruolo>" come membro di quel client
    Given un "<ruolo>" di "<ente>" ha caricato una chiave pubblica in quel client
    Given un "<ruolo>" di "<ente>" ha caricato una chiave pubblica in quel client
    Given un "<ruolo>" di "<ente>" ha caricato una chiave pubblica in quel client
    When l'utente richiede una operazione di listing delle chiavi di quel client
    Then si ottiene status code 200 e la lista di 3 chiavi

    Examples:
      | ente    | ruolo    |
      | GSP     | admin    |
      | PA1     | admin    |
      | Privato | admin    |
      | GSP     | security |
      | PA1     | security |
      | Privato | security |

  @client_keys_listing2a
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente non è membro del client; richiede l’elenco delle chiavi caricate per il client. L’operazione va a buon fine
    Given l'utente è un "<ruolo>" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "security" come membro di quel client
    Given un "security" di "PA1" ha caricato una chiave pubblica in quel client
    Given un "security" di "PA1" ha caricato una chiave pubblica in quel client
    Given un "security" di "PA1" ha caricato una chiave pubblica in quel client
    When l'utente richiede una operazione di listing delle chiavi di quel client
    Then si ottiene status code 200 e la lista di 3 chiavi

    Examples:
      | ruolo        |
      | admin        |
      | support      |

  # Errore: Attualmente security anche se non è membro del client può visualizzare le chiavi
  @client_keys_listing2b @wait_for_fix @PIN-5006
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente non è membro del client; richiede l’elenco delle chiavi caricate per il client. L’operazione va a buon fine
    Given l'utente è un "<ruolo>" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica in quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica in quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica in quel client
    When l'utente richiede una operazione di listing delle chiavi di quel client
    Then si ottiene status code 403

    Examples:
      | ruolo        |
      | api          |
      | security     |
      | api,security |

  @client_keys_listing3
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; richiede l’elenco delle chiavi caricate per il client da uno specifico utente. L’operazione va a buon fine (scopo del test è verificare il corretto funzionamento del parametro userIds)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "PA1" ha già inserito l'utente con ruolo "security" come membro di quel client
    Given un "security" di "PA1" ha caricato una chiave pubblica in quel client
    Given un "security" di "PA1" ha caricato una chiave pubblica in quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica in quel client
    When l'utente richiede una operazione di listing delle chiavi di quel client create dall'utente "security"
    Then si ottiene status code 200 e la lista di 2 chiavi

  @client_keys_listing4
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; richiede l’elenco delle chiavi caricate per il client; nel client non ci sono chiavi. L’operazione va a buon fine (scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    When l'utente richiede una operazione di listing delle chiavi di quel client create dall'utente "security"
    Then si ottiene status code 200 e la lista di 0 chiavi
