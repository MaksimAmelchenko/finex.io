@CashFlow.module 'ReferencesCategoriesApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Controller extends App.Controllers.Application
    initialize: (options) ->
      {item, config} = options
      #      ie or= App.request 'ie:entity', id

      editView = @getEditView item, config

      @form = App.request 'form:component', editView,
        proxy: 'dialog'

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model) ->
        @trigger event, model

      @show @form
#        loading: true

    getEditView: (item, config) ->
      new Edit.Category
        model: item
        config: config

