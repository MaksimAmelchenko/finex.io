@CashFlow.module 'DashboardBalancesApp', (DashboardBalancesApp, App, Backbone, Marionette, $, _) ->
  API =
    list: (region) ->
      new DashboardBalancesApp.List.Controller
        region: region

  App.commands.setHandler 'dashboard:balances', (region) ->
    API.list region
