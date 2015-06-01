@CashFlow.module 'PlansApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Layout extends App.Views.Layout
    template: 'plans/show/layout'
    className: 'container-fluid'

    regions:
      cashFlowItemsRegion: '[name=cashFlowItems-region]'
      transfersRegion: '[name=transfers-region]'
      exchangesRegion: '[name=exchanges-region]'
