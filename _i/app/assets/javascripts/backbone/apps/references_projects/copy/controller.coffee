@CashFlow.module 'ReferencesProjectsApp.Copy', (Copy, App, Backbone, Marionette, $, _) ->
  class Copy.Controller extends App.Controllers.Application
    initialize: (options) ->
      {config} = options

      copyView = @getCopyView config

      @form = App.request 'form:component', copyView,
        proxy: 'dialog'

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model, options) ->
        @trigger event, model, options if _.startsWith(event, 'form:')

      @show @form

    getCopyView: (config) ->
      new Copy.Layout
        config: config

