@descriptor_published_update
Feature: Aggiornamento di un descrittore già pubblicato
  Tutti gli utenti autorizzati di enti erogatori possono aggiornare la durata voucher e le soglie di carico di un descrittore già punlicato.

  @descriptor_published_update1
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato DRAFT, all’aggiornamento da parte di un utente autorizzato della durata del voucher e delle soglie di carico del descrittore, la bozza viene aggiornata correttamente
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "<ente>" ha già creato un e-service con un descrittore in stato "DRAFT"
    When l'utente aggiorna la durata del voucher e le soglie di carico di quel descrittore
    Then si ottiene status code <risultato>

    Examples: 
      | ente | ruolo        | risultato |
      | GSP  | admin        |       400 |
      | GSP  | api          |       400 |
      | GSP  | security     |       403 |
      | GSP  | api,security |       400 |
      | GSP  | support      |       403 |
      | PA1  | admin        |       400 |
      | PA1  | api          |       400 |
      | PA1  | security     |       403 |
      | PA1  | api,security |       400 |
      | PA1  | support      |       403 |

  @descriptor_published_update2
  Scenario Outline: Per un e-service che ha un solo descrittore, il quale è in stato PUBLISHED, SUSPENDED o DEPRECATED, all'aggiornamento della durata del voucher e delle soglie di carico, l'operazione va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato un e-service con un descrittore in stato "<statoVersione>"
    When l'utente aggiorna la durata del voucher e le soglie di carico di quel descrittore
    Then si ottiene status code <risultato>

    Examples: 
      | statoVersione | risultato |
      | PUBLISHED     |       200 |
      | SUSPENDED     |       200 |
      | DEPRECATED    |       200 |
      | ARCHIVED      |       400 |
      | DRAFT         |       400 |
