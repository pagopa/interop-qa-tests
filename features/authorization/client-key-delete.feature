@client_key_delete @wait_for_clarification
Feature: Cancellazione delle chiavi di un client
  Tutti gli utenti admin possono cancellare le chiavi del proprio client
  # assicurarci che ci sia il seguente test:
  # Un security quando viene rimosso da un client non deve poter cancellare le chiavi che ha caricato
  # Invece l'admin ha facoltà di cancellare le chiavi anche quando non è più membro del client
  # Un security può cancellare chiavi caricate da altri se è un membro del client? No?

  @client_key_delete1
  Scenario Outline: Un utente con sufficienti permessi (admin o security); appartenente all'ente che ha creato il client; il quale utente è membro del client; nel quale client c'è una chiave pubblica caricata da lui stesso richiede la cancellazione della chiave. L'operazione va a buon fine.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "<ruolo>" come membro di un client
    Given un "<ruolo>" di "<ente>" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code <statusCode>

    Examples:
      | ente    | ruolo    | statusCode |
      | GSP     | admin    |        200 |
      | GSP     | security |        200 |
      | PA1     | admin    |        200 |
      | PA1     | security |        200 |
      | Privato | admin    |        200 |
      | Privato | security |        200 |

  @client_key_delete2
  Scenario Outline: Un utente con sufficienti permessi (admin o security); appartenente all'ente che ha creato il client; il quale utente è membro del client; nel quale client c'è una chiave pubblica caricata da un altro utente con qualsiasi livello di permesso autorizzato a caricare una chiave (admin o security); richiede la cancellazione della chiave. L'operazione va a buon fine.
    Given l'utente è un "<ruolo1>" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "<ruolo1>" come membro di un client
    Given "PA1" ha già inserito l'utente con ruolo "<ruolo2>" come membro di un client
    Given un "<ruolo2>" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code <statusCode>

    Examples:
      | ruolo1   | ruolo2   | statusCode |
      | admin    | security |        200 |
      | security | admin    |        200 |

  @client_key_delete3
  Scenario Outline: Un utente con sufficienti permessi (admin o security); appartenente all'ente che ha creato il client; il quale utente non è membro del client; nel quale client c'è una chiave pubblica caricata da lui stesso richiede la cancellazione della chiave. L'operazione va a buon fine.
    Given l'utente è un "<ruolo>" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "<ruolo>" come membro di un client
    Given un "<ruolo>" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già rimosso l'utente con ruolo "<ruolo>" dai membri di quel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code <statusCode>

    Examples:
      | ruolo    | statusCode |
      | admin    |        200 |
      | security |        200 |


  @client_key_delete4
  Scenario Outline: Un utente con sufficienti permessi (admin o security); appartenente all'ente che ha creato il client; il quale utente non è membro del client; nel quale client c'è una chiave pubblica caricata da un altro utente con qualsiasi livello di permesso autorizzato a caricare una chiave (admin o security); richiede la cancellazione della chiave. L'operazione va a buon fine.
    Given l'utente è un "<ruolo1>" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "<ruolo2>" come membro di un client
    Given un "<ruolo2>" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code <statusCode>

    Examples:
      | ruolo1   | ruolo2   | statusCode |
      | admin    | security |        200 |
      | security | admin    |        200 |
