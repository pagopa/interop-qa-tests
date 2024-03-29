@document_upload
Feature: Caricamento di un documento di interfaccia
  Tutti gli utenti autorizzati di enti erogatori possono caricare un documento di interfaccia ai propri descrittori

  @document_upload1
  Scenario Outline: Per un e-service che eroga con una determinata tecnologia e che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di caricamento di un documento di interfaccia coerente con la tecnologia, da parte di un utente autorizzato, l'operazione avrà successo altrimenti restituirà errore.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato DRAFT e tecnologia "REST"
    When l'utente carica un documento di interfaccia di tipo "yaml"
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | risultato |
      | GSP  | admin        |       200 |
      | GSP  | api          |       200 |
      | GSP  | security     |       404 |
      | GSP  | api,security |       200 |
      | GSP  | support      |       404 |
      | PA1  | admin        |       200 |
      | PA1  | api          |       200 |
      | PA1  | security     |       404 |
      | PA1  | api,security |       200 |
      | PA1  | support      |       404 |


  @document_upload2
  Scenario Outline: Per un e-service che eroga con una determinata tecnologia e che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di caricamento di un documento di interfaccia coerente con la tecnologia, da parte di un utente autorizzato, l'operazione avrà successo altrimenti restituirà errore.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato DRAFT e tecnologia "<technology>"
    When l'utente carica un documento di interfaccia di tipo "<tipoFile>"
    Then si ottiene status code <risultato>

    Examples: 
      | technology | tipoFile | risultato |
      | REST       | yaml     |       200 |
      | REST       | json     |       200 |
      | REST       | wsdl     |       400 |
      | REST       | xml      |       400 |      
      | SOAP       | wsdl     |       200 |
      | SOAP       | xml      |       200 |
      | SOAP       | yaml     |       400 |
      | SOAP       | json     |       400 |

  @document_upload3
  Scenario Outline: Per un e-service che eroga con una determinata tecnologia e che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di caricamento di un documento di interfaccia coerente con la tecnologia, ma contenente il termine localhost, l'operazione restituirà errore.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato DRAFT e tecnologia "<technology>"
    When l'utente carica un documento di interfaccia di tipo "<tipoFile>" che contiene il termine localhost
    Then si ottiene status code 403

    Examples: 
      | technology | tipoFile |
      | REST       | yaml     |
      | REST       | json     |
      | SOAP       | wsdl     |
      | SOAP       | xml      |

  @document_upload4
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato NON DRAFT, alla richiesta di caricamento di un documento di interfaccia, l'operazione restituirà errore.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
    When l'utente carica un documento di interfaccia di tipo "yaml"
    Then si ottiene status code 400

    Examples: 
      | statoDescrittore |
      | PUBLISHED        |
      | SUSPENDED        |
      | DEPRECATED       |
      | ARCHIVED         |

  @document_upload5
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, e per il quale è già stato caricato un documento di interfaccia, alla richiesta di caricamento di un nuovo documento di interfaccia, l’operazione restituirà errore.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato "DRAFT"
    Given un "admin" di "PA1" ha già caricato un'interfaccia per quel descrittore
    When l'utente carica un documento di interfaccia di tipo "yaml"
    Then si ottiene status code 400
