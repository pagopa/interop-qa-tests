const assert = require('assert');
const { Given, When, Then } = require('@cucumber/cucumber');
const { isItFriday } = require('../../utils/is_it_friday');



Given('today is {string}', function (givenDay) {
  this.today = givenDay;
});

When('I ask whether it\'s Friday yet', function () {
  this.actualAnswer = isItFriday(this.today);
});

Then('I should be told {string}', function (expectedAnswer) {
  assert.strictEqual(this.actualAnswer, expectedAnswer);
});