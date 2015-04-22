@CashFlow.module 'DashboardApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Controller extends App.Controllers.Application

    initialize: ->
      @layout = @getLayoutView()

      @listenTo @layout, 'show', =>
        @showInvitations()
        @showBalances()
        @showAccountsBalancesDaily()

      @show @layout

    getLayoutView: ->
      new Show.Layout

    showInvitations: ->
      App.execute 'dashboard:invitations', @layout.invitationsRegion

    showBalances: ->
      App.execute 'dashboard:balances', @layout.balancesRegion

    showAccountsBalancesDaily: ->
      App.execute 'dashboard:accounts:balances:daily', @layout.balancesDailyRegion