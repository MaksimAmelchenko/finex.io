@CashFlow.module 'UsersApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {})->
      users = App.request 'user:entities'

      @layout = @getLayoutView users
      @listenTo @layout, 'show', =>
        @showPanel users
        @showList users

      @show @layout,
        loading:
          entities: users

    getLayoutView: (users) ->
      new List.Layout
        collection: users

    getPanelView: (users) ->
      new List.Panel
        collection: users

    showPanel: (users) ->
      panelView = @getPanelView users
      @show panelView,
        region: @layout.panelRegion

    showList: (users) ->
      listView = @getListView users

      @show listView,
        region: @layout.listRegion

    getListView: (users) ->
      new List.Users
        collection: users

