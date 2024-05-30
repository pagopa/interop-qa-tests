@client_keys_listing
Feature: Listing chiavi client
  Tutti gli utenti admin, security o support possono leggere la lista delle chiavi di un client a cui sono associati

  @client_keys_listing1a
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente è membro del client; richiede l’elenco delle chiavi caricate per il client. L’operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "<ente>" ha caricato una chiave pubblica in quel client
    Given un "admin" di "<ente>" ha caricato una chiave pubblica in quel client
    Given un "admin" di "<ente>" ha caricato una chiave pubblica in quel client
    When l'utente richiede una operazione di listing delle chiavi di quel client
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

  @client_keys_listing1b
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente non è membro del client; richiede l’elenco delle chiavi caricate per il client. L’operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "<ente>" ha caricato una chiave pubblica in quel client
    Given un "admin" di "<ente>" ha caricato una chiave pubblica in quel client
    Given un "admin" di "<ente>" ha caricato una chiave pubblica in quel client
    When l'utente richiede una operazione di listing delle chiavi di quel client
    Then si ottiene status code <statusCode>
# nota: mantenere la matrice poiché diversa da quella sopra
    Examples:
      | ente    | ruolo        | statusCode |
      | GSP     | api          |        403 |
      | GSP     | security     |        403 |
      | GSP     | support      |        200 |
      | GSP     | api,security |        403 |
      | PA1     | api          |        403 |
      | PA1     | security     |        403 |
      | PA1     | support      |        200 |
      | PA1     | api,security |        403 |
      | Privato | api          |        403 |
      | Privato | security     |        403 |
      | Privato | support      |        200 |
      | Privato | api,security |        403 |

  @client_keys_listing1c
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente non è membro del client; richiede l’elenco delle chiavi caricate per il client. L’operazione va a buon fine
  # nel test 1b l'utente che inserisce le chiavi deve essere membro del client, quindi chi crea le chiavi (admin) è escluso da quel test. Invece 1c inverte i ruoli per coprire il caso in cui admin non è membro del client
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "security" come membro di quel client
    Given un "security" di "PA1" ha caricato una chiave pubblica in quel client
    Given un "security" di "PA1" ha caricato una chiave pubblica in quel client
    Given un "security" di "PA1" ha caricato una chiave pubblica in quel client
    When l'utente richiede una operazione di listing delle chiavi di quel client
    Then si ottiene status code 200

  @client_keys_listing1d
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; il quale utente non è membro del client; richiede l’elenco delle chiavi caricate per il client. L’operazione va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "admin" come membro di quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica in quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica in quel client
    Given un "admin" di "PA1" ha caricato una chiave pubblica in quel client
    When l'utente richiede una operazione delle chiavi di quel client
    Then si ottiene status code 200 e la lista di 3 chiavi

  @client_keys_listing2
  Scenario Outline: Un utente admin; appartenente all'ente che ha creato il client; richiede l’elenco delle chiavi caricate per il client; nel client non ci sono chiavi. L’operazione va a buon fine (scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    When l'utente richiede una operazione delle chiavi di quel client caricate da "security"
    Then si ottiene status code 200 e la lista di 0 chiavi 
