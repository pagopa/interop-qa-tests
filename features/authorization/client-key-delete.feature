@client_key_delete
Feature: Cancellazione delle chiavi di un client
  Tutti gli utenti autorizzati possono cancellare le chiavi del proprio client, security solo le proprie

  @client_key_delete1
  Scenario Outline: Un utente con sufficienti permessi (admin o security); appartenente all'ente che ha creato il client; il quale utente è membro del client; nel quale client c'è una chiave pubblica caricata da lui stesso richiede la cancellazione della chiave. L'operazione va a buon fine.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "<ruolo>" come membro di quel client
    Given un "<ruolo>" di "<ente>" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code <statusCode>

    Examples: # Non testiamo gli altri ruoli in quanto non autorizzati per le operazioni preliminari
      | ente    | ruolo    | statusCode |
      | GSP     | admin    |        204 |
      | GSP     | security |        204 |
      | PA1     | admin    |        204 |
      | PA1     | security |        204 |
      | Privato | admin    |        204 |
      | Privato | security |        204 |

  @client_key_delete2 @wait_for_fix @PIN-4999
  Scenario Outline: Un utente con sufficienti permessi (admin o security); appartenente all'ente che ha creato il client; il quale utente è membro del client; nel quale client c'è una chiave pubblica caricata da un altro utente con qualsiasi livello di permesso autorizzato a caricare una chiave (admin o security); richiede la cancellazione della chiave. L'operazione va a buon fine solo per admin.
    Given l'utente è un "<ruoloCancellatore>" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "<ruoloCancellatore>" come membro di quel client
    Given "PA1" ha già inserito l'utente con ruolo "<ruoloCaricatore>" come membro di quel client
    Given un "<ruoloCaricatore>" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code <statusCode>

    Examples:
      | ruoloCancellatore | ruoloCaricatore | statusCode |
      | admin             | security        |        204 |
      | admin             | api,security    |        204 |
      | security          | admin           |        403 |
      | security          | api,security    |        403 |

  @client_key_delete3 @wait_for_fix @PIN-4999
  Scenario Outline: Un utente con sufficienti permessi (admin o security); appartenente all'ente che ha creato il client; il quale utente non è membro del client; nel quale client c'è una chiave pubblica caricata da lui stesso richiede la cancellazione della chiave. L'operazione va a buon fine solo per admin.
    Given l'utente è un "<ruolo>" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "<ruolo>" come membro di quel client
    Given un "<ruolo>" di "PA1" ha caricato una chiave pubblica nel client
    Given "PA1" ha già rimosso l'utente con ruolo "<ruolo>" dai membri di quel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code <statusCode>

    Examples:
      | ruolo    | statusCode |
      | admin    |        204 |
      | security |        403 |

  @client_key_delete4 @wait_for_fix @PIN-4999
  Scenario Outline: Un utente con sufficienti permessi (admin o security); appartenente all'ente che ha creato il client; il quale utente non è membro del client; nel quale client c'è una chiave pubblica caricata da un altro utente con qualsiasi livello di permesso autorizzato a caricare una chiave (admin o security); richiede la cancellazione della chiave. L'operazione va a buon fine solo per admin.
    Given l'utente è un "<ruoloCancellatore>" di "PA1"
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "<ruoloCaricatore>" come membro di quel client
    Given un "<ruoloCaricatore>" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede una operazione di cancellazione della chiave di quel client
    Then si ottiene status code <statusCode>

    Examples:
      | ruoloCancellatore | ruoloCaricatore | statusCode |
      | admin             | security        |        204 |
      | admin             | api,security    |        204 |
      | security          | admin           |        403 |
      | security          | api,security    |        403 |
