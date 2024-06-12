@client_key_read
Feature: Lettura di una chiave pubblica contenuta in un client
  Tutti gli utenti autenticati possono recuperare le informazione di una chiave pubblica contenuta in un client 

  @client_key_read1
  Scenario Outline: Un utente, il quale è appartenente all’ente al quale è associato un client; il quale utente non è membro del client; per il quale client c'è una chiave, caricata da un altro utente; richiede la lettura delle informazioni della chiave pubblica. L'operazione va a buon fine solo per admin, support, security
    Given l'utente è un "<ruoloUtente>" di "<ente>"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "<ente>" ha già creato 1 client "CONSUMER"
    Given "<ente>" ha già inserito l'utente con ruolo "<ruoloUploader>" come membro di un client
    Given un "<ruoloUploader>" di "<ente>" ha caricato una chiave pubblica nel client
    When l'utente richiede la lettura della chiave pubblica
    Then si ottiene status code <statusCode>

    Examples:
      | ente | ruoloUtente  | ruoloUploader | statusCode |
      | GSP  | admin        | admin         |        200 |
      | GSP  | api          | admin         |        403 |
      | GSP  | support      | admin         |        200 |
      | GSP  | api,security | admin         |        200 |
      | PA1  | admin        | admin         |        200 |
      | PA1  | api          | admin         |        403 |
      | PA1  | support      | admin         |        200 |
      | PA1  | api,security | admin         |        200 |

    Examples:
      | ente | ruoloUtente | ruoloUploader | statusCode |
      | PA1  | admin       | security      |        200 |
      | PA1  | security    | security      |        200 |

  # Lato backend non c'è nessun controllo
  @client_key_read2 @wait_for_clarification
  Scenario Outline: Un utente con permessi di security; il quale è appartenente all’ente al quale è associato un client; il quale utente è membro del client; per il quale client c'è una chiave, caricata da un altro utente; richiede la lettura delle informazioni della chiave pubblica. Ottiene un errore. NB: da verificare, non sono sicuro. I security forse si comportano come gli admin per i client ai quali sono associati
    Given l'utente è un "security" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "security" come membro di un client
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di un client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la lettura della chiave pubblica
    Then si ottiene status code 200

  @client_key_read3
  Scenario Outline: Un utente con permessi di security; il quale è appartenente all'ente al quale è associato un client; il quale utente non è membro del client; per il quale client c'è una chiave, caricata da un altro utente; richiede la lettura delle informazioni della chiave pubblica. Ottiene un errore
    Given l'utente è un "security" di "PA1"
    Given "PA2" ha già creato e pubblicato 1 e-service
    Given "PA1" ha già creato 1 client "CONSUMER"
    Given "PA1" ha già inserito l'utente con ruolo "admin" come membro di un client
    Given un "admin" di "PA1" ha caricato una chiave pubblica nel client
    When l'utente richiede la lettura della chiave pubblica
    Then si ottiene status code 200
