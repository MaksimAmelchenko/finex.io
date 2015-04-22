@CashFlow.module 'ReferencesMoneysApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Controller extends App.Controllers.Application
    initialize: (options) ->
      {money, config} = options

      editView = @getEditView money, config

      @form = App.request 'form:component', editView,
        proxy: 'dialog'

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model) ->
        @trigger event, model

      @show @form
#        loading: true

    getEditView: (money, config) ->
      new Edit.Money
        model: money
        config: config

