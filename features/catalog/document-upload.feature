@document_upload

Feature: Caricamento di un documento
  Tutti gli utenti autenticati di enti erogatori possono caricare un'interfaccia ai propri descrittori

  @document_upload1
  Scenario Outline: Per un e-service che eroga con una determinata tecnologia e che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di caricamento di un documento di interfaccia coerente con la tecnologia l'operazione avrà successo altrimenti errore. 
     Given l'utente è un "<ruolo>" di "<ente>"
     Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato DRAFT e tecnologia "<technology>"
     When l'utente carica un documento con estensione "<estensioneFile>"
     Then si ottiene status code <risultato>
   

    Examples: 
      | ente | ruolo |    technology | estensioneFile | risultato |
      | GSP  | admin |    REST       | .yml           |    200    |
      | GSP  | admin |    SOAP       | .wsdl          |    200    |
      | GSP  | admin |    SOAP       | .yml           |    500    |
      | GSP  | admin |    REST       | .wsdl          |    500    |

  @document_upload2
  Scenario Outline: Per un e-service che eroga con una determinata tecnologia e che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di caricamento di un documento di interfaccia coerente con la tecnologia, ma contenente il termine localhost, l'operazione restituirà errore. 
     Given l'utente è un "<ruolo>" di "<ente>"
     Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato DRAFT e tecnologia "<technology>"
     When l'utente carica un documento con estensione "<estensioneFile>" che contiene il termine localhost
     Then si ottiene status code 400

    Examples: 
      | ente | ruolo |    technology | estensioneFile|
      | GSP  | admin |    REST       | .yml          |
      | GSP  | admin |    SOAP       | .wsdl         |

  @document_upload3
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato NON DRAFT, alla richiesta di caricamento di un documento di interfaccia, l'operazione restituirà errore. 
     Given l'utente è un "<ruolo>" di "<ente>"
     Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
     When l'utente carica un documento con estensione ".yaml"
     Then si ottiene status code 400
 
    
    Examples: 
      | ente | ruolo | statoDescrittore  |
      | GSP  | admin |    PUBLISHED      |
      | GSP  | admin |    SUSPENDED      |  
      | GSP  | admin |    DEPRECATED     |  
      | GSP  | admin |    ARCHIVED       |  



@document_upload4
  Scenario Outline:  Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, alla richiesta di caricamento di un documento valido che abbia lo stesso nome e tipologia di un documento già precedentemente caricato, ottiene un errore (CHIEDERE DEMO A RUGG)
     Given l'utente è un "<ruolo>" di "<ente>"
     Given un "<ruolo>" di "<ente>" ha già creato un e-service con un descrittore in stato "<statoDescrittore>"
     Given l'utente 
     When l'utente carica un documento con estensione ".yaml"
     Then si ottiene status code 400

