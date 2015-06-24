@CashFlow.module 'PlansCashFlowItemsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application

    initialize: (options = {})->
      planCashFlowItems = App.request 'plan:cashFlowItem:entities',
        force: true

      @layout = @getLayoutView planCashFlowItems

      @listenTo @layout, 'show', =>
        @showPanel planCashFlowItems
        @showList planCashFlowItems

      @show @layout,
        loading: true

    getLayoutView: (planCashFlowItems) ->
      new List.Layout
        collection: planCashFlowItems

    showPanel: (planCashFlowItems) ->
      panelView = @getPanelView planCashFlowItems
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (planCashFlowItems) ->
      new List.Panel
        collection: planCashFlowItems

    showList: (planCashFlowItems) ->
      listView = @getListView planCashFlowItems

      @listenTo listView, 'childview:planCashFlowItem:clicked', (child, args) ->
        {model} = args

        if not getSelection().toString()
          model.collection.chooseNone()
          model.choose()

          App.request 'plan:cashFlowItem:edit', model, model.collection

      @show listView,
        region: @layout.listRegion

    getListView: (planCashFlowItems) ->
      new List.PlanCashFlowItems
        collection: planCashFlowItems