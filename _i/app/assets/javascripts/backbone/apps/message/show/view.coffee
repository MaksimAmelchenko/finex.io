@CashFlow.module 'MessageApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Message extends App.Views.ItemView
    template: false

    form:
      focusFirstInput: true

    dialog: ->
      title: @getTitle()
      keyboard: true
      backdrop: 'static'

    getTitle: ->
      @options.title

    initialize: (options = {}) ->
      @config = options.config

    onRender: ->
      @$el.html @options.message
