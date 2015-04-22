@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.CurrencyRateSource extends Entities.Model
    idAttribute: 'idCurrencyRateSource'

    defaults:
      idCurrencyRateSource: null
      name: ''

    parse: (response, options)->
      if not _.isUndefined response.currencyRateSource
        response = response.currencyRateSource
      response

  class Entities.CurrencyRateSources extends Entities.Collection

    model: Entities.CurrencyRateSource

    parse: (response, options)->
      response.currencyRateSources
