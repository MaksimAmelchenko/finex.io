@CashFlow.module 'CashFlowsExchangesApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Controller extends App.Controllers.Application
    initialize: (options) ->
      {exchange, config} = options

      editView = @getEditView exchange, config

      @form = App.request 'form:component', editView,
        proxy: 'dialog'

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model, options) ->
        @trigger event, model, options if _.startsWith(event, 'form:')

      @show @form

    getEditView: (exchange, config) ->
      new Edit.Exchange
        model: exchange
        config: config
