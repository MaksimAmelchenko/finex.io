@CashFlow.module 'UsersApp.Invite', (Invite, App, Backbone, Marionette, $, _) ->
  class Invite.Controller extends App.Controllers.Application
    initialize: (options) ->
      {config} = options

      inviteView = @getInviteView config

      @form = App.request 'form:component', inviteView,
        proxy: 'dialog'

      # Pass all events from 'form' to 'Controller'
      @listenTo @form, 'all', (event, model, options) ->
        @trigger event, model, options if _.startsWith(event, 'form:')

      @show @form

    getInviteView: (config) ->
      new Invite.User
        config: config

