@CashFlow.module 'DashboardBalancesApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application

    initialize: (options = {})->
      balances = App.entities.dashboardBalances
      balances.fetch()

      @layout = @getLayoutView balances

      @listenTo @layout, 'show', =>
        @showPanel balances
        @showList balances

      @show @layout,
        loading: true

    getLayoutView: (balances) ->
      new List.Layout
        model: balances

    showPanel: (balances) ->
      panelView = @getPanelView balances
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (balances) ->
      new List.Panel
        model: balances

    showList: (balances) ->
      listView = @getListView balances

      @show listView,
        region: @layout.listRegion

    getListView: (balances) ->
      new List.Balances
        model: balances