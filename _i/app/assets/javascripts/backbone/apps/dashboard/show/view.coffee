@CashFlow.module 'DashboardApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Layout extends App.Views.Layout
    template: 'dashboard/show/layout'
    className: 'container-fluid'

    regions:
      invitationsRegion: '[name=invitations-region]'
      balancesRegion: '[name=balances-region]'
      balancesDailyRegion: '[name=balancesDaily-region]'
