@CashFlow.module 'ReportsDynamicsApp', (ReportsDynamicsApp, App, Backbone, Marionette, $, _) ->
  class ReportsDynamicsApp.Router extends Marionette.AppRouter
    appRoutes:
      'reports/dynamics': 'show'

  #    before: ->
  #      App.vent.trigger 'nav:main:choose', 'references'

  API =
    show: ->
      ReportsDynamicsApp.show()

  App.addInitializer ->
    new ReportsDynamicsApp.Router
      controller: API

  @show = ->
    @showController = new ReportsDynamicsApp.Show.Controller()

  App.reqres.setHandler 'reports_dynamics:panel:height', ->
    ReportsDynamicsApp.showController.panelView.$el.height() if ReportsDynamicsApp.showController

