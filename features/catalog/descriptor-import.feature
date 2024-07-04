@descriptor_import
Feature: Import di un descrittore
  Tutti gli utenti autorizzati possono effettuare una richiesta di import di un descrittore di un e-service.

  @descriptor_import1
  Scenario Outline: La richiesta di import di un descrittore di un e-service da parte di un utente autorizzato, dato un pacchetto correttamente strutturato, contenente due documenti correttamente mappati nel file di configurazione, va a buon fine e il descrittore viene correttamente creato in stato DRAFT con quei documenti
    Given l'utente è un "<ruolo>" di "<ente>"
    Given l'utente ha già un pacchetto correttamente strutturato con un eservice in mode "DELIVER"
    Given l'utente ha già richiesto una presignedURL per il caricamento del pacchetto
    Given è già stato caricato il pacchetto nella presignedURL
    When l'utente effettua una richiesta di import del descrittore
    Then si ottiene status code 200
    And il descrittore viene correttamente creato in stato DRAFT 
    And i due documenti risultano correttamente caricati

    Examples:
      | ente | ruolo        |
      | PA1  | admin        |
      | PA1  | api          |
      | PA1  | api,security |
      | GSP  | admin        |
      | GSP  | api          |
      | GSP  | api,security |

  @descriptor_import2
  Scenario Outline: La richiesta di import di un descrittore di un e-service da parte di un utente non autorizzato, dato un pacchetto correttamente strutturato, contenente due documenti correttamente mappati nel file di configurazione, non va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given l'utente ha già un pacchetto correttamente strutturato con un eservice in mode "DELIVER"
    Given l'utente ha già richiesto una presignedURL per il caricamento del pacchetto
    Given è già stato caricato il pacchetto nella presignedURL
    When l'utente effettua una richiesta di import del descrittore
    Then si ottiene status code 500

    Examples:
      | ente | ruolo    |
      | PA1  | security |
      | PA1  | support  |
      | GSP  | security |
      | GSP  | support  |

  @descriptor_import3
  Scenario Outline: La richiesta di import di un descrittore di un e-service in erogazione inversa, dato un pacchetto correttamente strutturato, va a buon fine e il descrittore viene correttamente creato in stato DRAFT con l’analisi del rischio fornita dal pacchetto
    Given l'utente è un "admin" di "PA1"
    Given l'utente ha già un pacchetto correttamente strutturato con un eservice in mode "RECEIVE"
    Given l'utente ha già richiesto una presignedURL per il caricamento del pacchetto
    Given è già stato caricato il pacchetto nella presignedURL
    When l'utente effettua una richiesta di import del descrittore
    Then si ottiene status code 200
    And il descrittore viene correttamente creato in stato DRAFT 
    And l'eservice contiene l'analisi del rischio

  @descriptor_import4 @wait_for_fix
  Scenario Outline: La richiesta di import di un descrittore di un e-service, dato un pacchetto con il file di configurazione correttamente formattato ma con il nome del file errato, non va a buon fine.
    Given l'utente è un "admin" di "PA1"
    Given l'utente ha già un pacchetto correttamente strutturato con un eservice in mode "DELIVER"
    Given l'utente ha già richiesto una presignedURL per il caricamento del pacchetto
    Given è già stato caricato il pacchetto nella presignedURL
    When l'utente effettua una richiesta di import del descrittore con nome del file errato
    Then si ottiene status code 400

  @descriptor_import5
  Scenario Outline: La richiesta di import di un descrittore di un e-service, dato un pacchetto con il file di configurazione non correttamente formattato (campi richiesti mancanti o json non valido), non va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given l'utente ha già un pacchetto non correttamente strutturato con campi richiesti mancanti
    Given l'utente ha già richiesto una presignedURL per il caricamento del pacchetto
    Given è già stato caricato il pacchetto nella presignedURL
    When l'utente effettua una richiesta di import del descrittore
    Then si ottiene status code 400

  @descriptor_import6
  Scenario Outline: La richiesta di import di un descrittore di un e-service, dato un pacchetto con il file di configurazione correttamente formattato ma contenente documenti (o file di interfaccia) che non esistono nel percorso previsto, non va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given l'utente ha già un pacchetto non correttamente strutturato con documenti mancanti nel percorso previsto
    Given l'utente ha già richiesto una presignedURL per il caricamento del pacchetto
    Given è già stato caricato il pacchetto nella presignedURL
    When l'utente effettua una richiesta di import del descrittore
    Then si ottiene status code 400

  @descriptor_import7
  Scenario Outline: La richiesta di import di un descrittore di un e-service, dato un pacchetto con il file di configurazione correttamente formattato, ma con file in cartella non previsti all’interno del file di configurazione, non va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given l'utente ha già un pacchetto non correttamente strutturato con file non previsti
    Given l'utente ha già richiesto una presignedURL per il caricamento del pacchetto
    Given è già stato caricato il pacchetto nella presignedURL
    When l'utente effettua una richiesta di import del descrittore
    Then si ottiene status code 400

# Il controllo sui documenti da caricare e se il nome dell'eservice è già presente sono stati tralasciati in quanto già testati nei relativi endpoint dedicati
