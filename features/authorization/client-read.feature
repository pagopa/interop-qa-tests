@client_read
Feature: Lettura client singolo
  Tutti gli utenti autenticati possono leggere un singolo client

  @client_read1
  Scenario Outline: Un utente admin legge un client appartenente al proprio ente. La richiesta va a buon fine
    Given l'utente è un "admin" di "PA1"
    Given "PA1" ha già creato 1 client "e-service"
    When l'utente richiede una operazione di lettura di quel client 
    Then si ottiene status code 200

  @client_read2
  Scenario Outline: Un utente security legge un client del quale è membro. La richiesta va a buon fine
    Given l'utente è un "security" di "PA1"
    Given "PA1" ha già creato 1 client "e-service"
    Given "PA1" ha già inserito l'utente con ruolo "security" come membro di un client
    When l'utente richiede una operazione di lettura di quel client 
    Then si ottiene status code 200

  @client_read3
  Scenario Outline: Un utente security legge un client di un ente al quale è stato associato, ma del quale non è membro. Ottiene un errore
    Given l'utente è un "security" di "PA1"
    Given "PA1" ha già creato 1 client "e-service"
    When l'utente richiede una operazione di lettura di quel client 
    Then si ottiene status code 400

  @client_read4 @wait_for_clarification
  Scenario Outline: Un utente support legge un client di un ente per il quale sta operando. La richiesta va a buon fine

  @client_read5
  Scenario Outline: Un utente api legge un client dell'ente al quale è associato. Ottiene un errore
    Given l'utente è un "api" di "PA1"
    Given "PA1" ha già creato 1 client "e-service"
    Given "PA1" ha già inserito l'utente con ruolo "api" come membro di un client
    When l'utente richiede una operazione di lettura di quel client 
    Then si ottiene status code 400
