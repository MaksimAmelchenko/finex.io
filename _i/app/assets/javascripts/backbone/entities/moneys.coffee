@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Money extends Entities.Model
    idAttribute: 'idMoney'
    urlRoot: App.getServer() + '/moneys'

    initialize: ->
      new Backbone.Chooser(@)

    defaults:
      idMoney: null
      idUser: null
      idCurrency: null
      name: ''
      symbol: ''
      isEnabled: true
      precision: 2

    parse: (response, options)->
      if not _.isUndefined response.money
        response = response.money
      response

  class Entities.Moneys extends Entities.Collection

    model: Entities.Money
    url: 'moneys'
    parse: (response, options)->
      response.moneys

    initialize: ->
      new Backbone.MultiChooser(@)
  #      @.on 'change:name', =>
  #        @sort()

  #    comparator: (account) ->
  #      account.get('name')


  API =
    newMoneyEntity: ->
      new Entities.Money()

    getMoneyEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.moneys
        App.entities.moneys = new Entities.Moneys
        force = true

      moneys = App.entities.moneys

      if force
        selected = moneys.getChosen()
        moneys.fetch
          reset: true
          success: ->
            moneys.chooseByIds selected

      moneys

  App.reqres.setHandler 'money:new:entity', ->
    API.newMoneyEntity()

  App.reqres.setHandler 'money:entities', (options)->
    API.getMoneyEntities(options)

  App.reqres.setHandler 'enabled:money:entities', (idMoney) ->
    App.entities.moneys.filter (item) ->
      return item.get('isEnabled') or item.id is idMoney


  # sort list according to monies
  # list - array of objects like this: {idMoney: <idMoney>, ...}
  @sortListByMoney = (list) ->
    moneys = App.entities.moneys.pluck 'idMoney'
    if _.isNumber(list[0])
      _.sortBy list, (item) ->
        _.indexOf(moneys, item)
    else
      _.sortBy list, (item) ->
        _.indexOf(moneys, item.idMoney)
