@descriptor_draft_update
Feature: Aggiornamento di un descrittore in bozza
  Tutti gli utenti autorizzati di enti erogatori possono aggiornare tutti i parametri di un descrittore in bozza.

  @descriptor_draft_update1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, all’aggiornamento da parte di un utente autorizzato di alcuni parametri del descrittore, ben formattati, la bozza viene aggiornata correttamente
    Given l'utente è un "<ruolo>" di "<ente>"
    Given un "admin" di "<ente>" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente aggiorna alcuni parametri di quel descrittore
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | risultato |
      | GSP  | admin        |       200 |
      | GSP  | api          |       200 |
      | GSP  | security     |       403 |
      | GSP  | api,security |       200 |
      | GSP  | support      |       403 |
      | PA1  | admin        |       200 |
      | PA1  | api          |       200 |
      | PA1  | security     |       403 |
      | PA1  | api,security |       200 |
      | PA1  | support      |       403 |

  @descriptor_draft_update2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato NON DRAFT (PUBLISHED, SUSPENDED, DEPRECATED, ARCHIVED), all’aggiornamento di alcuni parametri del descrittore, ben formattati, l’aggiornamento della bozza restituisce errore
    Given l'utente è un "admin" di "PA1"
    Given un "admin" di "PA1" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente aggiorna alcuni parametri di quel descrittore
    Then si ottiene status code 400

    Examples: 
      | statoVersione |
      | PUBLISHED     |
      | SUSPENDED     |
      | DEPRECATED    |
      | ARCHIVED      |
