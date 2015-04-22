@CashFlow.module 'ReferencesUnitsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {})->
      {unit} = options
      units = App.request 'unit:entities'
      if unit
        units.chooseNone()
        units.choose unit

      @layout = @getLayoutView units
      @listenTo @layout, 'show', ->
        @showPanel units
        @showList units

      @show @layout,
        loading:
          entities: units

    getLayoutView: (units) ->
      new List.Layout
        collection: units

    showPanel: (units) ->
      panelView = @getPanelView units
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (units) ->
      new List.Panel
        collection: units

    showList: (units) ->
      listView = @getListView units

#      @listenTo listView, 'childview:unit:clicked', (child, args) ->
#        {model} = args
#
#        if model.get('idUser')
#          model.collection.chooseNone()
#          model.choose()
#
#          App.request 'unit:edit', model

      @show listView,
        region: @layout.listRegion

    getListView: (units) ->
      new List.Units
        collection: units
