@CashFlow.module 'MenuApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application

    initialize: (options) ->
      menu = App.request 'menu:entities'

      @layout = @getLayoutView menu
      @listenTo @layout, 'show', =>
        @showList menu

      @show @layout

    getLayoutView: (menu) ->
      new List.Layout
        collection: menu

    showList: (menu) ->
      listView = @getListView menu

      @show listView,
        region: @layout.listRegion

    getListView: (menu)->
      new List.Menu
        collection: menu


