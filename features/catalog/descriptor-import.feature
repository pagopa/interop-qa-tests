@descriptor_import
Feature: Import di un descrittore
  Tutti gli utenti autorizzati possono effettuare una richiesta di import di un descrittore di un e-service.

  @descriptor_import1
  Scenario Outline: La richiesta di import di un descrittore di un e-service, dato un pacchetto correttamente strutturato, contenente anche un documento correttamente mappato nel file di configurazione, va a buon fine e il descrittore viene correttamente creato in stato DRAFT con quel documento
    Given l'utente è un "<ruolo>" di "<ente>"
    Given l'utente ha già richiesto una presignedURL per il caricamento del pacchetto
    Given è già stato caricato il pacchetto nella presignedURL
    When l'utente effettua una richiesta di import del descrittore
    Then si ottiene status code 200
    # And il descrittore viene correttamente creato in stato DRAFT

    Examples:
      | ente | ruolo        |
      | GSP  | admin        |
      # | GSP  | api          |
      # | GSP  | security     |
      # | GSP  | api,security |
      # | GSP  | support      |
      # | PA1  | admin        |
      # | PA1  | api          |
      # | PA1  | security     |
      # | PA1  | api,security |
      # | PA1  | support      |

  @descriptor_import2
  Scenario Outline: La richiesta di export di un descrittore di un e-service, in stato DRAFT, ritorna un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente effettua una richiesta di export del descrittore
    Then si ottiene status code 400

  @descriptor_import3
  Scenario Outline: La richiesta di export di un descrittore di un e-service, senza documenti, da parte di un ente che non è l’erogatore, ritorna un errore
    Given l'utente è un "admin" di "PA1"
    Given "PA2" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    When l'utente effettua una richiesta di export del descrittore
    Then si ottiene status code 400

  @descriptor_import4
  Scenario Outline: La richiesta di export di un descrittore di un e-service, senza documenti, in erogazione inversa, con un’analisi del rischio compilata, va a buon fine. Il documento di configurazione che è parte del pacchetto esportato contiene anche l’analisi del rischio compilata dall’erogatore
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    When l'utente effettua una richiesta di export del descrittore
    Then si ottiene status code 200
    And il pacchetto risulta correttamente formattato
    And il documento di configurazione contiene anche l’analisi del rischio compilata dall’erogatore

  @descriptor_import5
  Scenario Outline: La richiesta di export di un descrittore di un e-service, con documenti, va a buon fine e vengono esportati anche i documenti
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "PUBLISHED"
    When l'utente effettua una richiesta di export del descrittore
    Then si ottiene status code 200
    And il pacchetto risulta correttamente formattato
    And il pacchetto contiene anche i documenti che sono mappati nel documento di configurazione
