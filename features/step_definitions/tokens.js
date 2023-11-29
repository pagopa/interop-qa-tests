const { Given } = require('@cucumber/cucumber');

const TOKEN = {
  'PagoPA S.p.A.': {
    admin: '',
  },
  'Comune di Milano': {
    security: ''
  },
  Sogecap: {
    admin: ''
  }
}

Given('l\'utente è un {string} di {string}', function(role, party) {
  this.token = TOKEN[party][role]
})