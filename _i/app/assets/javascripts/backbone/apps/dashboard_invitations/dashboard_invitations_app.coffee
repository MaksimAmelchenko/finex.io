@CashFlow.module 'DashboardInvitationsApp', (DashboardInvitationsApp, App, Backbone, Marionette, $, _) ->
  API =
    list: (region) ->
      new DashboardInvitationsApp.List.Controller
        region: region

  App.commands.setHandler 'dashboard:invitations', (region) ->
    API.list region
