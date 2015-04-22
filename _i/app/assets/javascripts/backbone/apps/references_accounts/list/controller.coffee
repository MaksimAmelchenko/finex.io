@CashFlow.module 'ReferencesAccountsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {})->
      {account} = options
      accounts = App.request 'account:entities'
      if account
        accounts.chooseNone()
        accounts.choose account

      @layout = @getLayoutView accounts
      @listenTo @layout, 'show', =>
        @showPanel accounts
        @showList accounts

      @show @layout,
        loading:
          entities: accounts

    getLayoutView: (accounts) ->
      new List.Layout
        collection: accounts

    showPanel: (accounts) ->
      panelView = @getPanelView accounts
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (accounts) ->
      new List.Panel
        collection: accounts

    showList: (accounts) ->
      listView = @getListView accounts

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

    getListView: (accounts) ->
      new List.Accounts
        collection: accounts