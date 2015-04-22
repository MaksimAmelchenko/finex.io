@CashFlow.module 'ReferencesAccountsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Controller extends App.Controllers.Application
    initialize: (options) ->
      {account, config} = options

      editView = @getEditView account, config

      @form = App.request 'form:component', editView,
        proxy: 'dialog'

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model) ->
        @trigger event, model

      @show @form
#        loading: true

    getEditView: (account, config) ->
      new Edit.Account
        model: account
        config: config

