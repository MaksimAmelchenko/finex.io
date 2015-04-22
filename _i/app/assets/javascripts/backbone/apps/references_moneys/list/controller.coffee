@CashFlow.module 'ReferencesMoneysApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {})->
      {money} = options
      moneys = App.request 'money:entities'
      if money
        moneys.chooseNone()
        moneys.choose money

      @layout = @getLayoutView moneys
      @listenTo @layout, 'show', =>
        @showPanel moneys
        @showList moneys

      @show @layout,
        loading:
          entities: moneys

    getLayoutView: (moneys) ->
      new List.Layout
        collection: moneys

    showPanel: (moneys) ->
      panelView = @getPanelView moneys
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (moneys) ->
      new List.Panel
        collection: moneys

    showList: (moneys) ->
      listView = @getListView moneys

#      @listenTo listView, 'childview:account:clicked', (child, args) ->
#        {model} = args
#
#        model.collection.chooseNone()
#        model.choose()
#
#        if model.get('permit') is 7
#          App.request 'account:edit', model

      @show listView,
        region: @layout.listRegion

    getListView: (moneys) ->
      new List.Moneys
        collection: moneys