@CashFlow.module 'CashFlowsExchangesApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {})->
      {exchange, force} = options

      exchanges = App.request 'exchange:entities',
        force: force

      if exchange
        exchanges.chooseNone()
        exchanges.choose exchange

      @layout = @getLayoutView exchanges
      @listenTo @layout, 'show', =>
        @showPanel exchanges
        @showList exchanges

      @show @layout,
        loading:
          entities: exchanges

    getLayoutView: (exchanges) ->
      new List.Layout
        collection: exchanges

    showPanel: (exchanges) ->
      panelView = @getPanelView exchanges
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (exchanges) ->
      new List.Panel
        collection: exchanges

    showList: (exchanges) ->
      listView = @getListView exchanges

      @listenTo listView, 'childview:exchange:clicked', (child, args) ->
        {model} = args

        if not getSelection().toString()
          model.collection.chooseNone()
          model.choose()

          App.request 'exchange:edit', model, model.collection

      @show listView,
        region: @layout.listRegion

    getListView: (exchanges) ->
      new List.Exchanges
        collection: exchanges