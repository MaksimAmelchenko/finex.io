@CashFlow.module 'PlansTransfersApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application

    initialize: (options = {})->
      planTransfers = App.request 'plan:transfer:entities',
        force: true

      @layout = @getLayoutView planTransfers

      @listenTo @layout, 'show', =>
        @showPanel planTransfers
        @showList planTransfers

      @show @layout,
        loading: true

    getLayoutView: (planTransfers) ->
      new List.Layout
        collection: planTransfers

    showPanel: (planTransfers) ->
      panelView = @getPanelView planTransfers
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (planTransfers) ->
      new List.Panel
        collection: planTransfers

    showList: (planTransfers) ->
      listView = @getListView planTransfers

      @listenTo listView, 'childview:planTransfer:clicked', (child, args) ->
        {model} = args

        if not getSelection().toString()
          model.collection.chooseNone()
          model.choose()

          App.request 'plan:transfer:edit', model, model.collection

      @show listView,
        region: @layout.listRegion

    getListView: (planTransfers) ->
      new List.PlanTransfers
        collection: planTransfers