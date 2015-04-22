@CashFlow.module 'HeaderApp', (HeaderApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    show: ->
      HeaderApp.showController = new HeaderApp.Show.Controller
        region: App.headerRegion

  HeaderApp.on 'start', ->
    API.show()

#  App.reqres.setHandler 'show:default:project', ->
##    HeaderApp.showController.showProject App.session.idProject
#    HeaderApp.showController.showProject App.session.project
#
#  App.reqres.setHandler 'refresh:project:list', ->
##    HeaderApp.showController.showProject App.session.idProject
#    HeaderApp.showController.showProjectsList()

