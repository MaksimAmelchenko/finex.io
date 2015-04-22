@CashFlow.module "DashboardApp", (DashboardApp, App, Backbone, Marionette, $, _) ->
  class DashboardApp.Router extends Marionette.AppRouter
    appRoutes:
      'dashboard': 'show'

  API =
    show: ->
      DashboardApp.show()

  @show = ->
    new DashboardApp.Show.Controller

  App.addInitializer ->
    new DashboardApp.Router
      controller: API
  