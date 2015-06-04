@CashFlow.module 'HeaderApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Controller extends App.Controllers.Application

    initialize: (options) ->
      @layout = @getLayoutView()
#      @listenTo @layout, 'show', =>
      @show @layout


    getLayoutView: ->
      new Show.Layout

