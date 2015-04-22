@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Currency extends Entities.Model
    idAttribute: 'idCurrency'

  class Entities.Currencies extends Entities.Collection

    model: Entities.Currency
    url: 'currencies'
    parse: (response, options)->
      response.currencies

