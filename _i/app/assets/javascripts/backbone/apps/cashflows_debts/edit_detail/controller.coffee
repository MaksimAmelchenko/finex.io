@CashFlow.module 'CashFlowsDebtsApp.EditDetail', (EditDetail, App, Backbone, Marionette, $, _) ->
  class EditDetail.Controller extends App.Controllers.Application
    initialize: (options) ->
      {detail, config} = options

      editView = @getEditView detail, config
      @form = App.request 'form:component', editView,
        proxy: 'dialog'

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model, options) ->
        @trigger event, model, options if _.startsWith(event, 'form:')

      @show @form

    getEditView: (detail, config) ->
      new EditDetail.Detail
        model: detail
        config: config
