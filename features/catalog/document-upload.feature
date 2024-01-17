@document_upload

Feature: Caricamento di un documento
  Tutti gli utenti autenticati di enti erogatori possono caricare un'interfaccia ai propri descrittori

  @document_upload1
  Scenario Outline: test estensione files (localhost non presente, stato sempre draft)
    # Given l'utente è un "<ruolo>" di "<ente>"
    # Given un "<ruolo>" di "<ente>" ha più creato un e-service con un descrittore in stato "DRAFT"
    # Given l'utente ha caricato un'interfaccia per quel descrittore
    # When l'utente carica un documento di interfaccia con estensione .yml, .yaml o .json
    # Then si ottiene status code 200

    Examples: 
      | ente | ruolo |    technology | estensioneFile | risultato |
      | GSP  | admin |    REST       | .yml           |    200    |
      | GSP  | admin |    SOAP       | .wsdl          |    200    |
      | GSP  | admin |    SOAP       | .yml           |    500    |
      | GSP  | admin |    REST       | .wsdl          |    500    |

  @document_upload2
  Scenario Outline: test localhost presente (è sempre draft!)
    # Given l'utente è un "<ruolo>" di "<ente>"
    # Given un "<ruolo>" di "<ente>" ha più creato un e-service con un descrittore in stato "DRAFT"
    # Given l'utente ha caricato un'interfaccia per quel descrittore CONTENENTE la stringa localhost
    # When l'utente carica un documento di interfaccia con estensione .yml, .yaml o .json
    # Then si ottiene status code 200

    Examples: 
      | ente | ruolo |    technology | estensioneFile| risultato |
      | GSP  | admin |    REST       | .yml          |    400    |
      | GSP  | admin |    SOAP       | .wsdl         |    400    |

  @document_upload3
  Scenario Outline: test statoDescrittore non valido (localhost non presente)
    # Given l'utente è un "<ruolo>" di "<ente>"
    # Given un "<ruolo>" di "<ente>" ha più creato un e-service con un descrittore in stato "DRAFT"
    # Given l'utente ha caricato un'interfaccia per quel descrittore
    # When l'utente carica un documento di interfaccia con estensione .yml, .yaml o .json
    # Then si ottiene status code 200

    Examples: 
      | ente | ruolo |    technology | statoDescrittore | estensioneFile | risultato |
      | GSP  | admin |    REST       |      PUBLISHED    | .yml          |    500    |
      | GSP  | admin |    REST       |      SUSPENDED    | .yml          |    500    |
      | GSP  | admin |    REST       |      DEPRECATED   | .yml          |    500    |
      | GSP  | admin |    REST       |      ARCHIVED     | .yml          |    500    |


