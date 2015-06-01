@CashFlow.module 'PlansApp', (PlansApp, App, Backbone, Marionette, $, _) ->
  class PlansApp.Router extends Marionette.AppRouter
    appRoutes:
      'plans': 'show'

  API =
    show: ->
      PlansApp.show()

  @show = ->
    new PlansApp.Show.Controller()

  App.addInitializer ->
    new PlansApp.Router
      controller: API
  