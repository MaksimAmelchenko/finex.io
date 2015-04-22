@CashFlow.module 'UsersApp', (UsersApp, App, Backbone, Marionette, $, _) ->
  class UsersApp.Router extends Marionette.AppRouter
    appRoutes:
      'users': 'list'

  API =
    list: ->
      UsersApp.list()

  App.addInitializer ->
    new UsersApp.Router
      controller: API

  @list = (region, tag) ->
    new UsersApp.List.Controller

  @invite = (config, region) ->
    new UsersApp.Invite.Controller
      config: config
      region: region

  # -----------------------------------------------------
  App.reqres.setHandler 'user:invite', (config, region = App.request 'dialog:region') ->
    inviteController = UsersApp.invite config, region

    inviteController.on 'form:after:save', ->
      inviteController.form.formLayout.trigger 'dialog:close'

    inviteController
