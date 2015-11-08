@CashFlow.module 'ReferencesUnitsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Controller extends App.Controllers.Application
    initialize: (options) ->
      {unit, config} = options

      editView = @getEditView unit, config

      @form = App.request 'form:component', editView,
        proxy: 'dialog'

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model, options) ->
        @trigger event, model, options if _.startsWith(event, 'form:')

      @show @form

    getEditView: (unit, config) ->
      new Edit.Unit
        model: unit
        config: config

