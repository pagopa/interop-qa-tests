@purpose_creation_deliver
Feature: Creazione finalità per e-service in erogazione diretta

    @purpose_creation_deliver1
    Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati. La richiesta va a buon fine.
      Given l'utente è un "<ruolo>" di "<ente>"
      Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
      Given "<ente>" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
      When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
      Then si ottiene status code <risultato>
      
      Examples:
      | ente | ruolo        | risultato |
      | PA1  | admin        |    200    |
      | PA1  | api          |    403    |
      | PA1  | security     |    403    |
      | PA1  | api,security |    403    |
      | PA1  | support      |    403    |
      | GSP  | admin        |    200    |
      | GSP  | api          |    403    |
      | GSP  | security     |    403    |
      | GSP  | api,security |    403    |
      | GSP  | support      |    403    |



    @purpose_creation_deliver2
    Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, e una finalità già in stato DRAFT per lo stesso   e-service, crea una nuova finalità con tutti i campi richiesti correttamente formattati. La richiesta va a buon fine. Spiega: è possibile creare più finalità sulla stessa richiesta di fruizione
      Given l'utente è un "admin" di "PA1"
      Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
      Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
      Given un "admin" di "PA1" ha già creato 1 finalità in stato "DRAFT" per quell'eservice
      When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
      Then si ottiene status code 200

    @purpose_creation_deliver3
    Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, la quale è in stato SUSPENDED, crea una nuova finalità con tutti i campi richiesti correttamente formattati. La richiesta va a buon fine. Spiega: è possibile creare una finalità anche se l’e-service è sospeso
        Given l'utente è un "admin" di "PA1"
        Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
        Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
        Given un "admin" di "PA2" ha già sospeso quell'e-service
        When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
        Then si ottiene status code 200


    @purpose_creation_deliver4a
    Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato NON ACTIVE (DRAFT, PENDING, SUSPENDED, ARCHIVED) per un e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore (NB: verificare status code).
      Given l'utente è un "admin" di "PA1"
      Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "<tipoApprovazione>"
      Given "PA1" ha una richiesta di fruizione in stato "<statoAgreement>" per quell'e-service
      When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
      Then si ottiene status code 400

    Examples: 
      | statoAgreement | tipoApprovazione |
      | DRAFT          | AUTOMATIC        |
      | PENDING        | MANUAL           |
      | SUSPENDED      | AUTOMATIC        |
      | ARCHIVED       | AUTOMATIC        |

    @purpose_creation_deliver4b
    Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato MISSING_CERTIFIED_ATTRIBUTES per un e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore (NB: verificare status code).
      Given l'utente è un "admin" di "<enteFruitore>"
      Given "<enteCertificatore>" ha creato un attributo certificato e lo ha assegnato a "<enteFruitore>"
      Given un "admin" di "<enteErogatore>" ha già creato un e-service in stato "PUBLISHED" che richiede quell'attributo certificato con approvazione "AUTOMATIC"
      Given "<enteFruitore>" ha una richiesta di fruizione in stato "DRAFT" per quell'e-service
      Given "<enteCertificatore>" ha già revocato quell'attributo a "<enteFruitore>"
      Given la richiesta di fruizione è passata in stato "MISSING_CERTIFIED_ATTRIBUTES"
      When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
      Then si ottiene status code 400

    Examples: 
      | enteFruitore | enteCertificatore | enteErogatore |
      | GSP          | PA2               | PA1           |

    @purpose_creation_deliver4c
    Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato REJECTED per un e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore (NB:    verificare status code).
      Given l'utente è un "admin" di "PA1"
      Given un "admin" di "PA2" ha già creato un e-service in stato "PUBLISHED" con approvazione "MANUAL"
      Given "PA1" ha una richiesta di fruizione in stato "PENDING" per quell'e-service
      Given un "admin" di "PA2" ha già rifiutato quella richiesta di fruizione
      When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
      Then si ottiene status code 400

    @purpose_creation_deliver5
    Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente NON ha già una richiesta di fruizione per una versione di e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati. Ottiene un errore (NB: verificare status code).
      Given l'utente è un "admin" di "PA1"
      Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
      When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati
      Then si ottiene status code 400

    @purpose_creation_deliver6
    Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati, il campo isFreeOfCharge valorizzato a true e il campo freeOfChargeReason non compilato. Ottiene un errore (NB: verificare status code). Spiega: non è possibile creare una finalità ad uso gratuito senza specificare qual è la ragione
      Given l'utente è un "admin" di "PA1"
      Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
      Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
      When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati, in modalità gratuita senza specificare una ragione
      Then si ottiene status code 400

    @purpose_creation_deliver7
    # Già gli altri test non aggiungono l'analisi del rischio. Quindi è utile testare questa cosa anche qui? Questo test è utile?
    # Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati ma senza riskAnalysis. La richiesta va a buon fine. Spiega: sugli endpoint di creazione e update viene fatta solo una validazione formale sulla riskAnalysis, mentre la validazione strutturale viene fatta     all’activate
      # Given l'utente è un "admin" di "PA1"
      # Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
      # Given "ente" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
      # When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati, ma senza analisi del rischio
      # Then si ottiene status code 200

    @purpose_creation_deliver8
    Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati con una riskAnalysis parzialmente compilata ma formattata correttamente (ossia sono compilati solo alcuni campi, ma quei campi sono compilati correttamente). La richiesta va a buon fine. Spiega: sugli endpoint di creazione e update viene fatta solo una validazione formale sulla riskAnalysis, mentre la validazione strutturale viene fatta all’activate
      Given l'utente è un "admin" di "PA1"
      Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
      Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
      When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati, con un'analisi del rischio parzialmente compilata ma formattata correttamente
      Then si ottiene status code 200

    @purpose_creation_deliver9
    Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = DELIVER, crea una nuova finalità con tutti i campi richiesti correttamente formattati con una riskAnalysis parzialmente compilata, che è formattata correttamente, ma la quale versione della riskAnalysis non è l’ultima disponibile per quella tipologia di ente (es. la versione corrente è la v2, viene compilata la v1). Ottiene un errore (NB: verificare status code). Spiega: non è possibile creare una finalità con una riskAnalysis nella versione sbagliata
      Given l'utente è un "admin" di "PA1"
      Given un "admin" di "PA2" ha già creato e pubblicato 1 e-service
      Given "PA1" ha una richiesta di fruizione in stato "ACTIVE" per quell'e-service
      When l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati, con un'analisi del rischio parzialmente compilata, formattata correttamente, ma con un template datato
      Then si ottiene status code 400

    @purpose_creation_deliver10
    Scenario Outline: Un utente con sufficienti permessi (admin); il cui ente ha già una richiesta di fruizione in stato ACTIVE per una versione di e-service, il quale ha mode = RECEIVE, crea una nuova finalità con tutti i campi richiesti correttamente formattati e passando una providerRiskAnalysisId valida per quell’e-service (ossia passando l’id di una riskAnalysis che ha compilato l'erogatore per quell'e-service in erogazione inversa). Ottiene un errore (NB: verificare status code). Spiega: non è possibile usare questo endpoint per creare finalità per e-service in erogazione inversa. Va usato POST /reverse/purposes
    // come testare questa cosa? Se usiamo i client tipizzati, non possiamo passare payload errati (endpoint di creazione non accetta riskAnalysisId)