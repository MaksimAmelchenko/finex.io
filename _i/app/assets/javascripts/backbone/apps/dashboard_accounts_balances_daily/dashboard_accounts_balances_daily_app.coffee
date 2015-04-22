@CashFlow.module 'DashboardAccountsBalancesDailyApp', (DashboardAccountsBalancesDailyApp, App, Backbone, Marionette, $, _) ->
  API =
    list: (region) ->
      new DashboardAccountsBalancesDailyApp.Show.Controller
        region: region

  App.commands.setHandler 'dashboard:accounts:balances:daily', (region) ->
    API.list region
