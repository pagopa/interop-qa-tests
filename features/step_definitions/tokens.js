const { Given } = require('@cucumber/cucumber');

const TOKEN = {
  GSP: {
    admin: '',
  },
  PA1: {
    security: '',
    "api,security": ''
  },
  Privato: {
    admin: ''
  }
}

Given('l\'utente è un {string} di {string}', function(role, party) {
  this.token = TOKEN[party][role]
})