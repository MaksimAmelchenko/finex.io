@CashFlow.module 'ReportsDistributionApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Controller extends App.Controllers.Application
    initialize: (options = {})->
      distribution = App.entities.reportDistribution

      distribution.fetch
        reset: true

      @layout = @getLayoutView distribution
      @listenTo @layout, 'show', =>
        @showPanel distribution
        @showData distribution

      @show @layout,
        loading: true

    getLayoutView: (distribution) ->
      new Show.Layout
        model: distribution

    showPanel: (distribution) ->
      @panelView = @getPanelView distribution
      @show @panelView,
        region: @layout.panelRegion

    getPanelView: (distribution) ->
      new Show.Panel
        model: distribution

    showData: (distribution) ->
      dataView = @getDataView distribution

      @show dataView,
        region: @layout.dataRegion
        forceShow: true


    getDataView: (distribution) ->
      new Show.Data
        model: distribution

  @getValue = (sum, valueType) ->
    switch valueType
      when 1 then sum[0]
      when 2 then sum[1]
      when 3 then Math.max(sum[1] - sum[0], 0)

