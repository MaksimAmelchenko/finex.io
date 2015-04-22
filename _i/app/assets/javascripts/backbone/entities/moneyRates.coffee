@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
#  class Entities.MoneyRate extends Entities.Model
#    idAttribute: 'idMoneyRate'
#    urlRoot: App.getServer() + '/moneys/123/rates'
#
#    initialize: ->
#      new Backbone.Chooser(@)
#
#    defaults:
#      idMoneyRate: null
#      idMoney: null
#      dRate: null
#      idCurrency: null
#      rate: null
#
#    parse: (response, options)->
#      if not _.isUndefined response.moneyRate
#        response = response.moneyRate
#      response
#
#  class Entities.MoneyRates extends Entities.Collection
#
#    model: Entities.MoneyRate
#    url: 'moneys/123/rates'
#    parse: (response, options)->
#      response.moneys
#
#    initialize: ->
#      new Backbone.MultiChooser(@)
#
#
#  API =
#    newMoneyRateEntity: ->
#      new Entities.MoneyRate
#        idCurrency: (App.request 'default:money').get('idCurrency')
#
#    getMoneyRateEntities: (options = {})->
#      moneyRates = new Entities.MoneyRates()
#      moneyRates.fetch()
#      moneyRates
#
#  App.reqres.setHandler 'money:rate:new:entity', ->
#    API.newMoneyRateEntity()
#
#  App.reqres.setHandler 'money:rate:entities', (options)->
#    API.getMoneyEntities(options)



