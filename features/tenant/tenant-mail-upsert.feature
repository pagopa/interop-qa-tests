@tenant-mail-upsert
Feature: Aggiunta o aggiornamento di una mail di contatto
  Tutti gli utenti autenticati possono aggiungere o aggiornare una mail di contatto

  @tenant-mail-upsert1
  Scenario Outline: Per un utente con sufficienti permessi (admin), alla richiesta di aggiunta di una mail di contatto compilando tutti i parametri (kind, address e description), va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede una operazione di aggiunta di una mail di contatto con description
    Then si ottiene status code <statusCode>

    Examples:
      | ente    | ruolo        | statusCode |
      | GSP     | admin        |        200 |
      | GSP     | api          |        400 |
      | GSP     | security     |        400 |
      | GSP     | api,security |        400 |
      | GSP     | support      |        400 |
      | PA1     | api          |        400 |
      | PA1     | admin        |        200 |
      | PA1     | security     |        400 |
      | PA1     | support      |        400 |
      | PA1     | api,security |        400 |
      | Privato | admin        |        200 |
      | Privato | api          |        400 |
      | Privato | security     |        400 |
      | Privato | support      |        400 |
      | Privato | api,security |        400 |

  @tenant-mail-upsert2
  Scenario Outline: Per un utente con sufficienti permessi (admin), alla richiesta di aggiunta di una mail di contatto compilando i parametri kind e address ma non description, va a buon fine
    Given l'utente è un "admin" di "PA1"
    When l'utente richiede una operazione di aggiunta di una mail di contatto senza description
    Then si ottiene status code 200

  @tenants-listing3
  Scenario Outline: Per un utente con sufficienti permessi (admin), alla richiesta di aggiornamento di una mail di contatto compilando i parametri kind e address ma non description, va a buon fine. Si verifica che il campo address sia stato sovrascritto correttamente. Spiega: la mail viene di fatto sostituita, non aggiunta alla precedente. Questo endpoint gestisce sia la prima creazione che l’aggiornamento. Dietro il backend tratta la mail come un array di un elemento, esponendo al frontend la gestione di un’unica mail di contatto. È stato pensato così perché sia scalabile in futuro con più indirizzi per lo stesso ente
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già inserito una mail di contatto
    When l'utente richiede una operazione di aggiornamento della mail di contatto senza description
    Then si ottiene status code 200 e la mail è stata aggiornata e non aggiunta
