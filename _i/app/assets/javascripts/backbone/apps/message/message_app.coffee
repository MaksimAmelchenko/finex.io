@CashFlow.module 'MessageApp', (MessageApp, App, Backbone, Marionette, $, _) ->
  App.reqres.setHandler 'message:show', (title, message, config = {}) ->
    new MessageApp.Show.Controller
      title: title
      message: message
      region: App.request 'dialog:region'