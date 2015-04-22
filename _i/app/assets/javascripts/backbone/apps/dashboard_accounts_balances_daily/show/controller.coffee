@CashFlow.module 'DashboardAccountsBalancesDailyApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Controller extends App.Controllers.Application
    initialize: (options = {})->
      balancesDaily = App.entities.dashboardAccountsBalancesDaily
      balancesDaily.fetch()

      @layout = @getLayoutView balancesDaily
      @listenTo @layout, 'show', =>
        @showPanel balancesDaily
        @showGraph balancesDaily

      @show @layout,
        loading: true

    getLayoutView: (balancesDaily) ->
      new Show.Layout
        model: balancesDaily

    showPanel: (balancesDaily) ->
      @panelView = @getPanelView balancesDaily
      @show @panelView,
        region: @layout.panelRegion

    getPanelView: (balancesDaily) ->
      new Show.Panel
        model: balancesDaily

    showGraph: (balancesDaily) ->
      graphView = @getGraphView balancesDaily

      @show graphView,
        region: @layout.graphRegion
        forceShow: true

    getGraphView: (balancesDaily) ->
      new Show.Graph
        model: balancesDaily

