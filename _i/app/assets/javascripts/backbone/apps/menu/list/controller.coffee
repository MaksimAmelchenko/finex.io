@CashFlow.module 'MenuApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application

    initialize: (options) ->
      menu = App.request 'menu:entities'
      projects = App.request 'project:entities'

      @layout = @getLayoutView menu
      @listenTo @layout, 'show', =>
        @showProjectsList projects
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

    showProjectsList: (projects) ->
      listView = @getProjectListView projects

      @show listView,
        region: @layout.projectRegion

    getProjectListView: (projects) ->
      new List.Project
        collection: projects



