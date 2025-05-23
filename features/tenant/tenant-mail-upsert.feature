@tenant_mail_upsert
Feature: Aggiunta o aggiornamento di una mail di contatto
  Tutti gli utenti autenticati possono aggiungere o aggiornare una mail di contatto

  @tenant_mail_upsert1 @no-parallel
  Scenario Outline: Per un utente con sufficienti permessi (admin), alla richiesta di aggiunta di una mail di contatto compilando tutti i parametri (kind, address e description), va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede una operazione di aggiunta di una mail di contatto con description
    Then si ottiene status code <statusCode>
    And aspetta che si aggiorni il readmodel

    Examples:
      | ente    | ruolo        | statusCode |
      | GSP     | admin        |        204 |
      | GSP     | api          |        403 |
      | GSP     | security     |        403 |
      | GSP     | api,security |        403 |
      | GSP     | support      |        403 |
      | PA1     | admin        |        204 |
      | PA1     | api          |        403 |
      | PA1     | security     |        403 |
      | PA1     | support      |        403 |
      | PA1     | api,security |        403 |
      | Privato | admin        |        204 |
      | Privato | api          |        403 |
      | Privato | security     |        403 |
      | Privato | support      |        403 |
      | Privato | api,security |        403 |

  @tenant_mail_upsert2 @no-parallel
  Scenario Outline: Per un utente con sufficienti permessi (admin), alla richiesta di aggiunta di una mail di contatto compilando i parametri kind e address ma non description, va a buon fine
    Given l'utente è un "admin" di "PA1"
    When l'utente richiede una operazione di aggiunta di una mail di contatto senza description
    Then si ottiene status code 204
    And aspetta che si aggiorni il readmodel

  @tenant_mail_upsert3 @no-parallel
  Scenario Outline: Per un utente con sufficienti permessi (admin), alla richiesta di aggiornamento di una mail di contatto compilando i parametri kind e address ma non description, va a buon fine. Si verifica che il campo address sia stato sovrascritto correttamente. Spiega: la mail viene di fatto sostituita, non aggiunta alla precedente. Questo endpoint gestisce sia la prima creazione che l’aggiornamento. Dietro il backend tratta la mail come un array di un elemento, esponendo al frontend la gestione di un’unica mail di contatto. È stato pensato così perché sia scalabile in futuro con più indirizzi per lo stesso ente
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già inserito una mail di contatto
    When l'utente richiede una operazione di aggiornamento della mail di contatto senza description
    Then si ottiene status code 204 e la mail è stata aggiornata e non aggiunta
    And aspetta che si aggiorni il readmodel

  @tenant_mail_upsert4 @no-parallel
  Scenario Outline: Per un utente con sufficienti permessi (admin), alla richiesta di aggiunta della stessa mail di contatto già presente, si ottiene un errore.
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già inserito una mail di contatto
    When l'utente richiede una operazione di aggiunta della stessa mail di contatto già inserita
    Then si ottiene status code 409
    And aspetta che si aggiorni il readmodel
