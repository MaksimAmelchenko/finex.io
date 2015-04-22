@CashFlow.module 'ImportApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Controller extends App.Controllers.Application

    initialize: ->
      @layout = @getLayoutView()

      @show @layout

    getLayoutView: ->
      new Show.Layout

