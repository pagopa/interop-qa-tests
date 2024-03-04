@agreement_activate
Feature: Attivazione richiesta di fruizione

  @agreement_activate1
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato PENDING (prima attivazione), con tutti gli attributi richiesti certificati, tutti gli attributi richiesti dichiarati dal fruitore, e tutti gli attributi richiesti verificati dall’erogatore, alla richiesta di attivazione da parte di un utente con sufficienti permessi dell’ente erogatore, va a buon fine
    Given l'utente è un "<ruolo>" di "<enteErogatore>"
    Given "PA2" possiede un attributo certificato
    Given "PA2" possiede un attributo dichiarato
    Given "PA2" crea un attributo verificato
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "MANUAL"
    Given "PA2" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given "<enteErogatore>" verifica l'attributo verificato a "PA2"
    When l'utente richiede una operazione di attivazione di quella richiesta di fruizione
    Then si ottiene status code <risultato>

    Examples: 
      | enteErogatore | ruolo        | risultato |
      | GSP           | admin        |       200 |
      | GSP           | api          |       403 |
      | GSP           | security     |       403 |
      | GSP           | support      |       403 |
      | GSP           | api,security |       403 |
      | PA1           | admin        |       200 |
      | PA1           | api          |       403 |
      | PA1           | security     |       403 |
      | PA1           | support      |       403 |
      | PA1           | api,security |       403 |

  @agreement_activate2
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato SUSPENDED (riattivazione), con tutti gli attributi richiesti certificati, tutti gli attributi richiesti dichiarati dal fruitore, e tutti gli attributi richiesti verificati dall’erogatore, alla richiesta di attivazione da parte di un utente con sufficienti permessi dell’ente erogatore, va a buon fine.
    Given l'utente è un "admin" di "PA1"
    Given "PA2" possiede un attributo certificato
    Given "PA2" possiede un attributo dichiarato
    Given "PA2" crea un attributo verificato
    Given un "admin" di "PA1" ha già creato un e-service in stato "PUBLISHED" che richiede quegli attributi con approvazione "AUTOMATIC"
    Given "PA2" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    Given "PA1" verifica l'attributo verificato a "PA2"
    Given "PA1" ha già approvato quella richiesta di fruizione
    Given "PA1" ha già sospeso quella richiesta di fruizione come "PRODUCER"
    Given "PA2" ha già sospeso quella richiesta di fruizione come "CONSUMER"
    When l'utente richiede una operazione di attivazione di quella richiesta di fruizione
    Then si ottiene status code 200

  @agreement_activate3
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato PENDING o SUSPENDED; con tutti gli attributi richiesti certificati, i quali sono due gruppi di due, dei quali il fruitore ne possiede uno per gruppo; tutti gli attributi richiesti dichiarati dal fruitore, i quali sono due gruppi di due, dei quali il fruitore ne possiede uno per gruppo; tutti gli attributi richiesti verificati dall’erogatore, i quali sono due gruppi di due, dei quali il fruitore ne possiede uno per gruppo; alla richiesta di attivazione da parte di un utente con sufficienti permessi dell’ente erogatore, va a buon fine.
    Given l'utente è un "<ruolo>" di "<enteErogatore>"
    Given due gruppi di due attributi certificati da "<enteCertificatore>", dei quali "<enteFruitore>" ne possiede uno per gruppo
    Given due gruppi di due attributi verificati, dei quali "<enteFruitore>" ne possiede uno per gruppo
    Given due gruppi di due attributi dichiarati, dei quali "<enteFruitore>" ne possiede uno per gruppo
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "<statoDescrittore>" che richiede quei gruppi di attributi con approvazione "MANUAL"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    When l'utente richiede una operazione di attivazione di quella richiesta di fruizione
    Then si ottiene status code 200

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | PA1          | PA2               | GSP           |

  @agreement_activate4a
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato ACTIVE, ARCHIVED, alla richiesta di attivazione da parte di un utente con sufficienti permessi dell’ente erogatore, ottiene un errore
    Given l'utente è un "<ruolo>" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "AUTOMATIC"
    Given "GSP" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
    When l'utente richiede una operazione di attivazione di quella richiesta di fruizione
    Then si ottiene status code 400

    Examples: 
      | statoAgreement |
      | ACTIVE         |
      | ARCHIVED       |

  @agreement_activate4b
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato MISSING_CERTIFIED_ATTRIBUTES, alla richiesta di attivazione da parte di un utente con sufficienti permessi dell’ente erogatore, ottiene un errore
    Given l'utente è un "<ruolo>" di "<enteErogatore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
    When l'utente richiede una operazione di attivazione di quella richiesta di fruizione
    Then si ottiene status code 400

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | PA1          | PA2               | GSP           |

  @agreement_activate4c
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato REJECTED, alla richiesta di attivazione da parte di un utente con sufficienti permessi dell’ente erogatore, ottiene un errore
    Given l'utente è un "<ruolo>" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given un "admin" di "GSP" ha già creato e inviato una richiesta di fruizione per quell'e-service ed è in attesa di approvazione
    Given un "admin" di "PA1" ha già rifiutato quella richiesta di fruizione
    When l'utente richiede una operazione di attivazione di quella richiesta di fruizione
    Then si ottiene status code 400

  @agreement_activate5
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato PENDING, alla richiesta di attivazione da parte di un utente con sufficienti permessi dell’ente fruitore, ottiene un errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
    Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
    When l'utente richiede una operazione di attivazione di quella richiesta di fruizione
    Then si ottiene status code 400

  @agreement_activate6
  Scenario Outline: Per una richiesta di fruizione precedentemente creata da un fruitore, la quale è in stato SUSPENDED (riattivazione), con uno o più attributi richiesti non posseduti dal fruitore, alla richiesta di attivazione da parte di un utente con sufficienti permessi dell’ente erogatore, ottiene un errore
    Given l'utente è un "<ruolo>" di "<enteErogatore>"
    Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
    Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
    Given "<enteFruitore>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
    Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
    Given la richiesta di fruizione è passata in stato "SUSPENDED"
    When l'utente richiede una operazione di attivazione di quella richiesta di fruizione
    Then si ottiene status code 400

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | PA1          | PA2               | GSP           |
