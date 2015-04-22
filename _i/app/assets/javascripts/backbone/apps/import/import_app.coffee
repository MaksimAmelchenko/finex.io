@CashFlow.module 'ImportApp', (ImportApp, App, Backbone, Marionette, $, _) ->

  class ImportApp.Router extends Marionette.AppRouter
    appRoutes:
      'import': 'show'
    
  API =
    show: ->
#      App.vent.trigger 'nav:main:choose', 'dashboard'
      new ImportApp.Show.Controller

      
  App.addInitializer ->
    new ImportApp.Router
      controller: API
  