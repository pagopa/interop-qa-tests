@tenant-read
Feature: Lettura di un singolo aderente
  Tutti gli utenti autenticati possono leggere un singolo aderente

  @tenant-read1
  Scenario Outline: Per un aderente della piattaforma, alla richiesta di lettura da parte di qualsiasi livello di permesso associato a qualsiasi tipologia di ente, va a buon fine
    Given l'utente è un "<ruolo>" di "<ente>"
    When l'utente richiede la lettura di un aderente
    Then si ottiene status code "200"

    Examples:
      | ente    | ruolo        |
      | GSP     | admin        |
      | GSP     | api          |
      | GSP     | security     |
      | GSP     | api,security |
      | GSP     | support      |
      | PA1     | api          |
      | PA1     | admin        |
      | PA1     | security     |
      | PA1     | support      |
      | PA1     | api,security |
      | Privato | admin        |
      | Privato | api          |
      | Privato | security     |
      | Privato | support      |
      | Privato | api,security |

    @tenants-listing2
  Scenario Outline: Restituisce gli aderenti che contengono la keyword "comune" all'interno del nome, con ricerca case insensitive (scopo del test è verificare che funzioni il filtro name)
    Given l'utente è un "admin" di "PA1"
    When l'utente richiede una operazione di listing degli aderenti filtrando per la keyword "comune"
    Then si ottiene status code 200 e la lista di 1 aderente

    @tenants-listing3
  Scenario Outline: Restituisce un insieme vuoto di aderenti per una ricerca che non porta risultati (scopo del test è verificare che, se non ci sono risultati, il server risponda con 200 e array vuoto e non con un errore)
    Given l'utente è un "admin" di "PA1"
    When l'utente richiede una operazione di listing degli aderenti senza ricevere risultato 
    Then si ottiene status code 200 e la lista di 0 aderenti