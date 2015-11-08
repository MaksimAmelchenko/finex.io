@CashFlow.module 'ReferencesProjectsApp.Merge', (Merge, App, Backbone, Marionette, $, _) ->
  class Merge.Controller extends App.Controllers.Application
    initialize: (options) ->
      {config} = options

      mergeView = @getMergeView config

      @form = App.request 'form:component', mergeView,
        proxy: 'dialog'

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model, options) ->
        @trigger event, model, options if _.startsWith(event, 'form:')

      @show @form

    getMergeView: (config) ->
      new Merge.Layout
        config: config

