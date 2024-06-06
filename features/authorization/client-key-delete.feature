@client_key_delete @wait_for_clarification
Feature: Cancellazione delle chiavi di un client
  Tutti gli utenti admin possono cancellare le chiavi del proprio client

  # assicurarci che ci sia il seguente test:
  # Un security quando viene rimosso da un client non deve poter cancellare le chiavi che ha caricato
  # Invece l'admin ha facoltà di cancellare le chiavi anche quando non è più membro del client

  # Un security può cancellare chiavi caricate da altri se è un membro del client? No?

  @client_key_delete1a @wait_for_fix @PIN-4961
  Scenario Outline: Un utente senza sufficienti permessi; appartenente all'ente che ha creato il client; il quale utente è membro del client; nel quale client c'è una chiave pubblica; la quale chiave è caricata da un altro utente; richiede la cancellazione della chiave. L'operazione non va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "admin" come membro di un client
    Given un "admin" di "<ente>" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code 403

    Examples:
      | ente | ruolo        |
      | GSP  | api          |
      | GSP  | security     |
      | GSP  | support      |
      | GSP  | api,security |
      | PA1  | api          |
      | PA1  | security     |
      | PA1  | support      |
      | PA1  | api,security |

  @client_key_delete1b
  Scenario Outline: Un utente con sufficienti permessi (admin); appartenente all'ente che ha creato il client; il quale utente è membro del client; nel quale client c'è una chiave pubblica; la quale chiave è caricata da un altro utente; richiede la cancellazione della chiave. L'operazione va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "security" come membro di un client
    Given un "security" di "<ente>" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code 204

    Examples:
      | ente | ruolo        |
      | GSP  | admin        |
      | PA1  | admin        |

  @client_key_delete2 @wait_for_fix @PIN-4961
  Scenario Outline: Un utente admin, api o security, appartenente all'ente che ha creato il client, il quale utente NON è membro del client, nel quale client c'è una chiave pubblica, richiede la cancellazione della chiave. L'operazione va a buon fine solo per il ruolo admin
    Given l'utente è un "<ruoloCancellatore>" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "<ruoloCaricatore>" come membro di un client
    Given un "<ruoloCaricatore>" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code <statusCode>

    Examples:
      | ruoloCancellatore | ruoloCaricatore | statusCode |
      | security          | admin           |        403 |
      | api               | admin           |        403 |
      | admin             | security        |        204 |

  @client_key_delete3
  Scenario Outline: Un utente con permessi security; appartenente all'ente che ha creato il client; il quale utente NON è membro del client; nel quale client c'è una chiave pubblica; la quale chiave è caricata da un altro utente; richiede la cancellazione della chiave. Ottiene un errore
    Given l'utente è un "security" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code 403

  @client_key_delete4
  Scenario Outline: Un utente con permessi security; appartenente all'ente che ha creato il client; il quale utente NON è membro del client; nel quale client c'è una chiave pubblica; la quale chiave è caricata da questo utente; richiede la cancellazione della chiave. L’operazione va a buon fine
    Given l'utente è un "security" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given un "security" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code 204
