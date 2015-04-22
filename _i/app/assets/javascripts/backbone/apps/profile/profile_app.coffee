@CashFlow.module 'ProfileApp', (ProfileApp, App, Backbone, Marionette, $, _) ->
  class ProfileApp.Router extends Marionette.AppRouter
    appRoutes:
      'profile': 'edit'

    before: ->
#      App.vent.trigger 'nav:main:choose', 'references'

  API =
    edit: ->
      ProfileApp.edit()

  App.addInitializer ->
    new ProfileApp.Router
      controller: API

  @edit = ->
    new ProfileApp.Edit.Controller
      profile: App.entities.profile


