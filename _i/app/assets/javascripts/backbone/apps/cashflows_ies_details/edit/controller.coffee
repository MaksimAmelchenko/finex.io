@CashFlow.module 'CashFlowsIEsDetailsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Controller extends App.Controllers.Application
    initialize: (options) ->
      {ieDetail, config} = options

      editView = @getEditView ieDetail, config

      @form = App.request 'form:component', editView,
        proxy: 'dialog'

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model, options) ->
        @trigger event, model, options if s.startsWith(event, 'form:')

      @show @form

    getEditView: (ieDetail, config) ->
      new Edit.IEDetail
        model: ieDetail
        config: config

