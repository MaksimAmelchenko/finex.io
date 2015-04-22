@CashFlow.module 'ReferencesContractorsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {})->
      {contractor} = options
      contractors = App.request 'contractor:entities'
      if contractor
        contractors.chooseNone()
        contractors.choose contractor

      @layout = @getLayoutView contractors
      @listenTo @layout, 'show', ->
        @showPanel contractors
        @showList contractors

      @show @layout,
        loading:
          entities: contractors

    getLayoutView: (contractors)->
      new List.Layout
        collection: contractors

    showPanel: (contractors) ->
      panelView = @getPanelView contractors
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (contractors) ->
      new List.Panel
        collection: contractors

    showList: (contractors) ->
      listView = @getListView contractors

#      @listenTo listView, 'childview:contractor:clicked', (child, args) ->
#        {model} = args
#
#        model.collection.chooseNone()
#        model.choose()
#
#        App.request 'contractor:edit', model

      @show listView,
        region: @layout.listRegion

    getListView: (contractors) ->
      new List.Contractors
        collection: contractors