@CashFlow.module 'CashFlowsDebtsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {})->
      # default debt
      {debt, force} = options

      debts = App.request 'debt:entities',
        force: force

      if debt
        debts.chooseNone()
        debts.choose debt

      @layout = @getLayoutView debts
      @listenTo @layout, 'show', ->
        @showPanel debts
        @showDebts debts

      @show @layout,
        loading:
          entities: debts

    getLayoutView: (debts) ->
      new List.Layout
        collection: debts

    showPanel: (debts) ->
      panelView = @getPanelView debts
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (debts) ->
      new List.Panel
        collection: debts

    showDebts: (debts) ->
      debtsView = @getDebtsView debts

      @listenTo debtsView, 'childview:debt:clicked', (child, args) ->
        {model} = args

        if not getSelection().toString()
          model.collection.chooseNone()
          model.choose()

          App.request 'debt:edit', model, @region

      @show debtsView,
        region: @layout.listRegion

    getDebtsView: (debts) ->
      new List.Debts
        collection: debts
