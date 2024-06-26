@tenant-mail-delete
Feature: Cancellazione di una mail da parte di un aderente
  Tutti gli utenti autenticati possono cancellare una mail di contatte di un aderente in cui fanno parte

  @tenant-mail-delete1
  Scenario Outline: Per un utente con sufficienti permessi (admin), alla richiesta di cancellazione di una mail di contatto precedentemente aggiunta, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    Given "PA1" ha già inserito una mail di contatto
    When l'utente richiede la cancellazione di quella mail
    Then si ottiene status code "<statusCode>"

     Examples:
      | ente    | ruolo        | statusCode |
      | GSP     | admin        |        204 |
      | GSP     | api          |        400 |
      | GSP     | security     |        400 |
      | GSP     | api,security |        400 |
      | GSP     | support      |        400 |
      | PA1     | api          |        400 |
      | PA1     | admin        |        204 |
      | PA1     | security     |        400 |
      | PA1     | support      |        400 |
      | PA1     | api,security |        400 |
      | Privato | admin        |        204 |
      | Privato | api          |        400 |
      | Privato | security     |        400 |
      | Privato | support      |        400 |
      | Privato | api,security |        400 |