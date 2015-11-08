@CashFlow.module 'ProfileApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Controller extends App.Controllers.Application
    initialize: (options) ->
      {profile, config} = options

      editView = @getEditView profile, config

      @form = App.request 'form:component', editView
      #        proxy: 'dialog'

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model, options) ->
        @trigger event, model, options if _.startsWith(event, 'form:')

      @show @form

    getEditView: (profile, config) ->
      new Edit.Profile
        model: profile
        config: config

