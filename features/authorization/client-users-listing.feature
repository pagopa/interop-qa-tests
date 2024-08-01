@client_users_listing
Feature: Listing utenti client
  Tutti gli utenti autorizzati o security possono leggere la lista dei membri di un client a cui sono associati

  @client_users_listing1a
  Scenario Outline: Un utente API richiede la lista dei membri del client. Ritorna errore 403.
    Given l'utente è un "api" di "<ente>"
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "<ente>" ha già inserito l'utente con ruolo "security" come membro di quel client
    Given "<ente>" ha già inserito l'utente con ruolo "api,security" come membro di quel client
    When l'utente richiede una operazione di listing dei membri di quel client
    Then si ottiene status code 403

    Examples:
      | ente    |
      | GSP     |
      | PA1     |
      | Privato |

  @client_users_listing1b
  Scenario Outline: Un utente associato ad un client, di ruolo non API, richiede la lista dei membri del client stesso. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given "<ente>" ha già inserito l'utente con ruolo "security" come membro di quel client
    Given "<ente>" ha già inserito l'utente con ruolo "api,security" come membro di quel client
    When l'utente richiede una operazione di listing dei membri di quel client
    Then si ottiene status code 200 e la lista di 3 utenti

    Examples:
      | ente    | ruolo        |
      | GSP     | admin        |
      | GSP     | security     |
      | GSP     | support      |
      | GSP     | api,security |
      | PA1     | admin        |
      | PA1     | security     |
      | PA1     | support      |
      | PA1     | api,security |
      | Privato | admin        |
      | Privato | security     |
      | Privato | support      |
      | Privato | api,security |

  @client_users_listing2
  Scenario Outline: Un utente con permessi admin; appartenente all'ente che ha creato il client; richiede la lista dei membri del client; non ci sono membri del client. L'operazione va a buon fine (scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    When l'utente richiede una operazione di listing dei membri di quel client
    Then si ottiene status code 200 e la lista di 0 utenti
