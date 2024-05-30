@client_users_listing
Feature: Listing utenti client
  Tutti gli utenti admin o security possono leggere la lista dei membri di un client a cui sono associati

  @client_users_listing1a
  Scenario Outline: Un utente associato ad un client (dunque con permessi admin o security) richiede la lista dei membri del client stesso. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "admin" come membro di un client
    Given "<ente>" ha già inserito l'utente con ruolo "security" come membro di un client
    Given "<ente>" ha già inserito l'utente con ruolo "api,security" come membro di un client
    When l'utente richiede una operazione di listing dei client
    Then si ottiene status code <statusCode>

    Examples:
      | ente    | ruolo        | statusCode |
      | GSP     | admin        |        200 |
      | GSP     | api          |        403 |
      | GSP     | security     |        200 |
      | GSP     | support      |        200 |
      | GSP     | api,security |        200 |
      | PA1     | admin        |        200 |
      | PA1     | api          |        403 |
      | PA1     | security     |        200 |
      | PA1     | support      |        200 |
      | PA1     | api,security |        200 |
      | Privato | admin        |        200 |
      | Privato | api          |        403 |
      | Privato | security     |        200 |
      | Privato | support      |        200 |
      | Privato | api,security |        200 |

  @client_users_listing1b
  Scenario Outline: Un utente associato ad un client (dunque con permessi admin o security) richiede la lista dei membri del client stesso. L'operazione va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di un client
    Given "PA1" ha già inserito l'utente con ruolo "security" come membro di un client
    Given "PA1" ha già inserito l'utente con ruolo "api,security" come membro di un client
    When l'utente richiede una operazione di listing dei client
    Then si ottiene status code 200 e la lista di 3 utenti

  @client_users_listing2
  Scenario Outline: Un utente con permessi admin; appartenente all'ente che ha creato il client; richiede la lista dei membri del client; non ci sono membri del client. L'operazione va a buon fine (scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha già creato 1 client "CONSUMER"
    When l'utente richiede una operazione di listing dei client
    Then si ottiene status code 200 e la lista di 0 utenti
