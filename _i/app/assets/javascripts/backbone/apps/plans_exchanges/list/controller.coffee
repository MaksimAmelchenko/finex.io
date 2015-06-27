@CashFlow.module 'PlansExchangesApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application

    initialize: (options = {})->
      planExchanges = App.request 'plan:exchange:entities',
        force: true

      @layout = @getLayoutView planExchanges

      @listenTo @layout, 'show', =>
        @showPanel planExchanges
        @showList planExchanges

      @show @layout,
        loading: true

    getLayoutView: (planExchanges) ->
      new List.Layout
        collection: planExchanges

    showPanel: (planExchanges) ->
      panelView = @getPanelView planExchanges
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (planExchanges) ->
      new List.Panel
        collection: planExchanges

    showList: (planExchanges) ->
      listView = @getListView planExchanges

      @listenTo listView, 'childview:planExchange:clicked', (child, args) ->
        {model} = args

        if not getSelection().toString()
          model.collection.chooseNone()
          model.choose()

          App.request 'plan:exchange:edit', model, model.collection

      @show listView,
        region: @layout.listRegion

    getListView: (planExchanges) ->
      new List.PlanExchanges
        collection: planExchanges