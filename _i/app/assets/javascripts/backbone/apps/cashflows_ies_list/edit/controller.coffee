@CashFlow.module 'CashFlowsIEsListApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Controller extends App.Controllers.Application
    initialize: (options) ->
      {ie, config} = options
      editView = @getEditView ie, config

      @form = App.request 'form:component', editView

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model, options) ->
        @trigger event, model, options if _.startsWith(event, 'form:')

      App.execute 'when:fetched', ie, =>
        # Make a copy of ieDetail's collection and edit it
        @options.ie.set '_ieDetails', new App.Entities.IEDetails(@options.ie.get('ieDetails')),
          silent: true

      @show @form,
        loading: true

    onDestroy: ->
      @options.ie.unset '_ieDetails',
        silent: true

    getEditView: (ie, config) ->
      new Edit.IE
        model: ie
        config: config
