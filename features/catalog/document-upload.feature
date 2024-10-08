@document_upload
Feature: Caricamento di un documento di interfaccia
  Tutti gli utenti autorizzati di enti erogatori possono caricare un documento di interfaccia ai propri descrittori

  @document_upload1
  Scenario Outline: Per un e-service che eroga con una determinata tecnologia e che ha un solo descrittore, il quale è in uno dei sequenti stati: (PUBLISHED, DRAFT, DEPRECATED, SUSPENDED), alla richiesta di caricamento di un documento di interfaccia coerente con la tecnologia, da parte di un utente autorizzato, l'operazione avrà successo solo per lo stato DRAFT, altrimenti restituirà errore.
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>" e tecnologia "REST"
    When l'utente carica un documento di interfaccia di tipo "yaml"
    Then si ottiene status code <risultato>

    Examples:
      | ente | ruolo        | statoDescrittore | risultato |
      | GSP  | admin        | DRAFT            |       200 |
      | GSP  | api          | DRAFT            |       200 |
      | GSP  | security     | DRAFT            |       404 |
      | GSP  | api,security | DRAFT            |       200 |
      | GSP  | support      | DRAFT            |       403 |
      | PA1  | admin        | DRAFT            |       200 |
      | PA1  | api          | DRAFT            |       200 |
      | PA1  | security     | DRAFT            |       404 |
      | PA1  | api,security | DRAFT            |       200 |
      | PA1  | support      | DRAFT            |       403 |

    Examples: # Test sugli stati
      | ente | ruolo | statoDescrittore | risultato |
      | PA1  | admin | PUBLISHED        |       400 |
      | PA1  | admin | SUSPENDED        |       400 |
      | PA1  | admin | DEPRECATED       |       400 |
      | PA1  | admin | ARCHIVED         |       400 |

  @document_upload2
  Scenario Outline: Per un e-service che eroga con una determinata tecnologia e che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di caricamento di un documento di interfaccia coerente con la tecnologia, da parte di un utente autorizzato, l'operazione avrà successo altrimenti restituirà errore.
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "DRAFT" e tecnologia "<technology>"
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
    Given "PA1" ha già creato un e-service con un descrittore in stato "DRAFT" e tecnologia "<technology>"
    When l'utente carica un documento di interfaccia di tipo "<tipoFile>" che contiene il termine localhost
    Then si ottiene status code 403

    Examples:
      | technology | tipoFile |
      | REST       | yaml     |
      | REST       | json     |
      | SOAP       | wsdl     |
      | SOAP       | xml      |

  @document_upload4
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, e per il quale è già stato caricato un documento di interfaccia, alla richiesta di caricamento di un nuovo documento di interfaccia, l’operazione restituirà errore.
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "DRAFT"
    Given "PA1" ha già caricato un'interfaccia per quel descrittore
    When l'utente carica un documento di interfaccia di tipo "yaml"
    Then si ottiene status code 400

  @document_upload5
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, e per il quale è già stato caricato un documento, alla richiesta di caricamento di un nuovo documento con lo stesso nome, l’operazione restituirà errore.
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "DRAFT"
    Given "PA1" ha già caricato un documento con nome "test" in quel descrittore
    When l'utente carica un documento con nome "test" in quel descrittore
    Then si ottiene status code 409
