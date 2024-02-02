@document_upload
Feature: Caricamento di un documento di interfaccia
  Tutti gli utenti autorizzati di enti erogatori possono caricare un documento di interfaccia ai propri descrittori

  @document_upload1
  Scenario Outline: Per un e-service che eroga con una determinata tecnologia e che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di caricamento di un documento di interfaccia coerente con la tecnologia, da parte di un utente autorizzato, l'operazione avrà successo altrimenti restituirà errore.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato DRAFT e tecnologia "<technology>"
    When l'utente carica un documento di interfaccia di tipo "<tipoFile>"
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | technology | tipoFile | risultato |
      | GSP  | admin        | REST       | yaml     |       200 |
      | GSP  | admin        | SOAP       | wsdl     |       200 |
      | GSP  | admin        | SOAP       | yaml     |       400 |
      | GSP  | admin        | REST       | wsdl     |       400 |
      | GSP  | api          | REST       | yaml     |       200 |
      | GSP  | api          | SOAP       | wsdl     |       200 |
      | GSP  | api          | SOAP       | yaml     |       400 |
      | GSP  | api          | REST       | wsdl     |       400 |
      | GSP  | security     | REST       | yaml     |       403 |
      | GSP  | security     | SOAP       | wsdl     |       403 |
      | GSP  | security     | SOAP       | yaml     |       400 |
      | GSP  | security     | REST       | wsdl     |       400 |
      | GSP  | api,security | REST       | yaml     |       200 |
      | GSP  | api,security | SOAP       | wsdl     |       200 |
      | GSP  | api,security | SOAP       | yaml     |       400 |
      | GSP  | api,security | REST       | wsdl     |       400 |
      | GSP  | support      | REST       | yaml     |       403 |
      | GSP  | support      | SOAP       | wsdl     |       403 |
      | GSP  | support      | SOAP       | yaml     |       400 |
      | GSP  | support      | REST       | wsdl     |       400 |
      | PA1  | admin        | REST       | yaml     |       200 |
      | PA1  | admin        | SOAP       | wsdl     |       200 |
      | PA1  | admin        | SOAP       | yaml     |       400 |
      | PA1  | admin        | REST       | wsdl     |       400 |
      | PA1  | api          | REST       | yaml     |       200 |
      | PA1  | api          | SOAP       | wsdl     |       200 |
      | PA1  | api          | SOAP       | yaml     |       400 |
      | PA1  | api          | REST       | wsdl     |       400 |
      | PA1  | security     | REST       | yaml     |       403 |
      | PA1  | security     | SOAP       | wsdl     |       403 |
      | PA1  | security     | SOAP       | yaml     |       400 |
      | PA1  | security     | REST       | wsdl     |       400 |
      | PA1  | api,security | REST       | yaml     |       200 |
      | PA1  | api,security | SOAP       | wsdl     |       200 |
      | PA1  | api,security | SOAP       | yaml     |       400 |
      | PA1  | api,security | REST       | wsdl     |       400 |
      | PA1  | support      | REST       | yaml     |       403 |
      | PA1  | support      | SOAP       | wsdl     |       403 |
      | PA1  | support      | SOAP       | yaml     |       400 |
      | PA1  | support      | REST       | wsdl     |       400 |

  @document_upload2
  Scenario Outline: Per un e-service che eroga con una determinata tecnologia e che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di caricamento di un documento di interfaccia coerente con la tecnologia, ma contenente il termine localhost, l'operazione restituirà errore.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato DRAFT e tecnologia "<technology>"
    When l'utente carica un documento di interfaccia di tipo "<tipoFile>" che contiene il termine localhost
    Then si ottiene status code 403

    Examples: 
      | technology | tipoFile |
      | REST       | yaml     |
      | SOAP       | wsdl     |

  @document_upload3
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

  @document_upload4
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, e per il quale è già stato caricato un documento di interfaccia, alla richiesta di caricamento di un nuovo documento di interfaccia, l’operazione restituirà errore.
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato "DRAFT"
    Given un "admin" di "PA1" ha già caricato un'interfaccia per quel descrittore
    When l'utente carica un documento di interfaccia di tipo "yaml"
    Then si ottiene status code 400
