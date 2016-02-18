@CashFlow.module 'ReportsDynamicsApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Controller extends App.Controllers.Application
    initialize: (options = {})->
      dynamics = App.entities.reportDynamics

      dynamics.fetch
        reset: true

      @layout = @getLayoutView dynamics
      @listenTo @layout, 'show', =>
        @showPanel dynamics
        @showData dynamics

      @show @layout,
        loading: true

    getLayoutView: (dynamics) ->
      new Show.Layout
        model: dynamics

    showPanel: (dynamics) ->
      @panelView = @getPanelView dynamics
      @show @panelView,
        region: @layout.panelRegion

    getPanelView: (dynamics) ->
      new Show.Panel
        model: dynamics

    showData: (dynamics) ->
      dataView = @getDataView dynamics

      @show dataView,
        region: @layout.dataRegion

    getDataView: (dynamics) ->
      new Show.Data
        model: dynamics

  @getValue = (sum, valueType) ->
    switch valueType
      when 1 then sum[0]
      when 2 then sum[1]
      when 3 then Math.max(sum[1] - sum[0], 0)
      when 4 then sum[0] - sum[1]

