@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Exchange extends Entities.Model
    idAttribute: 'idExchange'
    urlRoot: App.getServer() + '/cashflows/exchanges'

    initialize: ->
      new Backbone.Chooser(@)

    defaults:
      idExchange: null
      idUser: null
      dExchange: null
      reportPeriod: null
      idAccountFrom: null
      sumFrom: null
      idCurrencyFrom: null
      idAccountTo: null
      sumTo: null
      idCurrencyTo: null
    #
      isFee: false
      idAccountFee: null
      fee: null
      idCurrencyFee: null
    #
      note: ''
      tags: []



    parse: (response, options)->
      if not _.isUndefined response.exchange
        response = response.exchange
      response

  #-----------------------------------------------------------------------

  class Entities.Exchanges extends Entities.Collection

    model: Entities.Exchange
    url: 'cashflows/exchanges'
    initialize: ->
      new Backbone.MultiChooser(@)
      @on 'change:dExchange', =>
        @sort()

      @searchText = ''

      @isUseFilters = false
      @filters =
        dBegin: null
        dEnd: null
        contractors: []
        accountsFrom: []
        accountsTo: []
        tags: []

    resetFilters: ->
      @filters.contractors = []
      @filters.accountsFrom = []
      @filters.accountsTo = []
      @filters.tags = []

    comparator: (exchange1, exchange2) ->
      dExchange1 = moment(exchange1.get('dExchange'), 'YYYY-MM-DD').toDate().getTime()
      dExchange2 = moment(exchange2.get('dExchange'), 'YYYY-MM-DD').toDate().getTime()
      if dExchange1 > dExchange2
        -1
      else
        if dExchange1 < dExchange2
          1
        else
          if exchange1.id > exchange2.id
            -1
          else
            if exchange1.id < exchange2.id
              1
            else
              0

    parse: (response, options)->
      @total = response.metadata.total
      @limit = response.metadata.limit
      @offset = response.metadata.offset
      response.exchanges

    data: ->
      result =
        limit: @limit
        offset: @offset
        searchText: @searchText
      if @isUseFilters
        result = $.extend result,
          dBegin: @filters.dBegin
          dEnd: @filters.dEnd
          contractors: @filters.contractors.toString()
          accountsFrom: @filters.accountsFrom.toString()
          accountsTo: @filters.accountsTo.toString()
          tags: @filters.tags.toString()
      result

  API =
    newExchangeEntity: ->
      new Entities.Exchange
        dExchange: App.request 'default:date'
        reportPeriod: App.request 'default:reportPeriod'
        idMoneyFrom: (App.request 'default:money')?.get('idMoney')
        isFee: false


    getExchangeEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.exchanges
        App.entities.exchanges = new Entities.Exchanges
        force = true

      exchanges = App.entities.exchanges

      if force
        selected = exchanges.getChosen()
        exchanges.fetch
          reset: true
          success: ->
            exchanges.chooseByIds selected

      exchanges


  App.reqres.setHandler 'exchange:new:entity', ->
    API.newExchangeEntity()

  App.reqres.setHandler 'exchange:entities', (options)->
    API.getExchangeEntities(options)
