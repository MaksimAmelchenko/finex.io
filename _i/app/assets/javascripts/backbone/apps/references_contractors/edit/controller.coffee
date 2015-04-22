@CashFlow.module 'ReferencesContractorsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Controller extends App.Controllers.Application
    initialize: (options) ->
      {contractor, config} = options

      editView = @getEditView contractor, config

      @form = App.request 'form:component', editView,
        proxy: 'dialog'

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model) ->
        @trigger event, model

      @show @form
#        loading: true

    getEditView: (contractor, config) ->
      new Edit.Contractor
        model: contractor
        config: config

