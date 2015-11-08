@CashFlow.module 'ReferencesCategoriesApp.Move', (Move, App, Backbone, Marionette, $, _) ->
  class Move.Controller extends App.Controllers.Application
    initialize: (options) ->
      {config} = options

      moveView = @getMoveView config

      @form = App.request 'form:component', moveView,
        proxy: 'dialog'

      # Pass all events from 'form' to 'Edit.Controller'
      @listenTo @form, 'all', (event, model, options) ->
        @trigger event, model, options if _.startsWith(event, 'form:')

      @show @form

    getMoveView: (config) ->
      new Move.Layout
        config: config

