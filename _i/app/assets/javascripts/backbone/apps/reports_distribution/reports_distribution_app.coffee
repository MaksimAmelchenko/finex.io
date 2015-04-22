@CashFlow.module 'ReportsDistributionApp', (ReportsDistributionApp, App, Backbone, Marionette, $, _) ->
  class ReportsDistributionApp.Router extends Marionette.AppRouter
    appRoutes:
      'reports/distribution': 'show'

  #    before: ->
  #      App.vent.trigger 'nav:main:choose', 'references'

  API =
    show: ->
      ReportsDistributionApp.show()

  App.addInitializer ->
    new ReportsDistributionApp.Router
      controller: API

  @show = ->
    @showController = new ReportsDistributionApp.Show.Controller()

  App.reqres.setHandler 'reports_distribution:panel:height', ->
    ReportsDistributionApp.showController.panelView.$el.height() if ReportsDistributionApp.showController

