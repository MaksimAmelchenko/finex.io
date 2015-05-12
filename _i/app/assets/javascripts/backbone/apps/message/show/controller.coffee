@CashFlow.module 'MessageApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Controller extends App.Controllers.Application
    initialize: (options) ->
      {title, message, config} = options

      showView = @getShowView title, message, config

      @show showView

    getShowView: (title, message, config) ->
      new Show.Message
        title: title
        message: message
        config: config

