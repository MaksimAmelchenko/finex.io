@CashFlow.module 'PlansApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Controller extends App.Controllers.Application

    initialize: ->
      @layout = @getLayoutView()

      @listenTo @layout, 'show', =>
        @showCashFlowItems()
        @showTransfers()
        @showExchanges()

      @show @layout

    getLayoutView: ->
      new Show.Layout

    showCashFlowItems: ->
      App.execute 'plans:cashFlowItems', @layout.cashFlowItemsRegion

    showTransfers: ->
      App.execute 'plans:transfers', @layout.transfersRegion

    showExchanges: ->
      App.execute 'plans:exchanges', @layout.exchangesRegion