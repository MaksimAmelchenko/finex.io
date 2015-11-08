@CashFlow.module 'CashFlowsDebtsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Controller extends App.Controllers.Application
    initialize: (options) ->
      {debt, config} = options

      editView = @getEditView debt, config

      # Make a copy of debtDetail's collection and edit it
      debt.set '_debtDetails', new App.Entities.DebtDetails(debt.get('debtDetails')),
        silent: true

      @form = App.request 'form:component', editView

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model, options) ->
        @trigger event, model, options if _.startsWith(event, 'form:')

      @show @form

    onDestroy: ->
      @options.debt.unset '_debtDetails',
        silent: true

    getEditView: (debt, config) ->
      new Edit.Debt
        model: debt
        config: config



