@CashFlow.module 'CashFlowsTransfersApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {})->
      {transfer, force} = options

      transfers = App.request 'transfer:entities',
        force: force

      if transfer
        transfers.chooseNone()
        transfers.choose transfer

      @layout = @getLayoutView transfers
      @listenTo @layout, 'show', =>
        @showPanel transfers
        @showList transfers

      @show @layout,
        loading:
          entities: transfers

    getLayoutView: (transfers) ->
      new List.Layout
        collection: transfers

    showPanel: (transfers) ->
      panelView = @getPanelView transfers
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (transfers) ->
      new List.Panel
        collection: transfers

    showList: (transfers) ->
      listView = @getListView transfers

      @listenTo listView, 'childview:transfer:clicked', (child, args) ->
        {model} = args

        if not getSelection().toString()
          model.collection.chooseNone()
          model.choose()

          App.request 'transfer:edit', model, model.collection

      @show listView,
        region: @layout.listRegion

    getListView: (transfers) ->
      new List.Transfers
        collection: transfers