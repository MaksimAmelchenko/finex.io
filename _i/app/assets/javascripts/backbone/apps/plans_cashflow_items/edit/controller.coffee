@CashFlow.module 'PlansCashFlowItemsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Controller extends App.Controllers.Application
    initialize: (options) ->
      {model, config} = options

      editView = @getEditView model, config

      @form = App.request 'form:component', editView,
        proxy: 'dialog'

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model, options) ->
        @trigger event, model, options if s.startsWith(event, 'form:')

      @show @form

    getEditView: (model, config) ->
      new Edit.PlanCashFlowItem
        model: model
        config: config

