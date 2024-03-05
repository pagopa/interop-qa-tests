@agreement_suspension
Feature: Sospensione richiesta di fruizione
    @agreement_suspension1
    Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE, alla richiesta di sospensione da parte di un utente con sufficienti permessi (admin) dell’ente fruitore, che non coincide con l’ente erogatore, va a buon fine
    
      Given l'utente è un "admin" di "<enteFruitore>"
      Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
      Given "<enteFruitore>" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
      Given "<enteErogatore>" ha già attivato quella richiesta di fruizione
      When l'utente richiede una operazione di sospensione di quella richiesta di fruizione
      Then si ottiene status code 200

      Examples:
        | enteFruitore | enteErogatore |
        |     PA1      | PA2           |

    @agreement_suspension2
    Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE, alla richiesta di sospensione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, che non coincide con l’ente fruitore, va a buon fine
    
      Given l'utente è un "admin" di "<enteErogatore>"
      Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
      Given "<enteFruitore>" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
      Given "<enteErogatore>" ha già attivato quella richiesta di fruizione
      When l'utente richiede una operazione di sospensione di quella richiesta di fruizione
      Then si ottiene status code 200

    Examples:
        | enteFruitore | enteErogatore |
        |     PA1      |      PA2      |


    @agreement_suspension3
    Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore e attivata da un erogatore, la quale è in stato ACTIVE, alla richiesta di sospensione da parte di un utente con sufficienti permessi (admin) dell’ente erogatore, che coincide con l’ente fruitore, va a buon fine
    
    Given l'utente è un "admin" di "<enteErogatore>"
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    When l'utente richiede una operazione di sospensione di quella richiesta di fruizione
    Then si ottiene status code 200

    Examples:
        | enteFruitore | enteErogatore |
        |     PA1      |    PA1        |

    @agreement_suspension4a
    Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato NON ACTIVE (PENDING, DRAFT, SUSPENDED, ARCHIVED), alla richiesta di sospensione da parte di un utente con sufficienti permessi (admin), ottiene un errore (NB: verificare status code)
    
    Given l'utente è un "admin" di "<ente>"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "<tipoApprovazione>"
    Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente richiede una operazione di sospensione di quella richiesta di fruizione
    Then si ottiene status code <risultato>
# Situazione attuale nel caso del SUSPENDED: se è già stata sospesa da fruitore:
# 1 richiesta di sospensione da parte del fruitore va a buon fine
# 2 richiesta di sospensione da parte dell'erogatore va a buon fine
# Il caso 1 va a buon fine per idempotenza, poiché effettua di nuovo la stessa operazione
# Il caso 2 va a buon fine perché va ad aggiungere un altro flag "suspended by"
    Examples: 
        | statoAgreement | tipoApprovazione |  ente  | risultato |
        | DRAFT          |   AUTOMATIC      |   PA1  |   400     |  
        | PENDING        |   MANUAL         |   PA1  |   400     |  
        | SUSPENDED      |   AUTOMATIC      |   PA1  |   200     |  
        | ARCHIVED       |   AUTOMATIC      |   PA1  |   400     |  
        | DRAFT          |   AUTOMATIC      |   PA2  |   400     |  
        | PENDING        |   MANUAL         |   PA2  |   400     |  
        | SUSPENDED      |   AUTOMATIC      |   PA2  |   200     |  
        | ARCHIVED       |   AUTOMATIC      |   PA2  |   400     |

    @agreement_suspension4b
    Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato REJECTED, alla richiesta di sospensione da parte di un utente con sufficienti permessi (admin), ottiene un errore (NB: verificare status code)
    
    Given l'utente è un "admin" di "<ente>"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given un "admin" di "PA1" ha già creato e inviato una richiesta di fruizione per quell'e-service ed è in attesa di approvazione
    Given un "admin" di "PA2" ha già rifiutato quella richiesta di fruizione
    When l'utente richiede una operazione di sospensione di quella richiesta di fruizione
    Then si ottiene status code 400

    Examples:
        | ente |
        | PA1  |
        | PA2  |

    @agreement_suspension4c
    Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato MISSING_CERTIFIED_ATTRIBUTES, alla richiesta di sospensione da parte di un utente con sufficienti permessi (admin), ottiene un errore (NB: verificare status code)
    
    Given l'utente è un "admin" di "<ente>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    When l'utente richiede una operazione di sospensione di quella richiesta di fruizione
    Then si ottiene status code 400

    Examples:
        | enteFruitore | enteCertificatore | enteErogatore | ente |
        | PA1          | PA2               | GSP           |  PA1 |
        | PA1          | PA2               | GSP           |  GSP |

