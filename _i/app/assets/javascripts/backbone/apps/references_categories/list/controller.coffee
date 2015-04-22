@CashFlow.module 'ReferencesCategoriesApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {})->
      {item} = options
      items = App.request 'category:entities'

      if item
#        items.chooseNone()
        items.choose item

      @layout = @getLayoutView items
      @listenTo @layout, 'show', ->
        @showPanel items
        @showList items

      @show @layout,
        loading:
          entities: items

    getLayoutView: (items) ->
      new List.Layout
        collection: items

    showPanel: (items) ->
      panelView = @getPanelView items
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (items) ->
      new List.Panel
        collection: items


    showList: (items) ->
      listView = @getListView items

      @show listView,
        region: @layout.listRegion

    getListView: (items) ->
      new List.Categories
        collection: items
