@CashFlow.module 'CashFlowsIEsDetailsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {})->
      {force} = options

      ieDetails = App.request 'ie:detail:entities',
        force: force

      @layout = @getLayoutView ieDetails

      @listenTo @layout, 'show', =>
        @showPanel ieDetails
        @showList ieDetails

      @show @layout,
        loading:
          entities: ieDetails

    getLayoutView: (ieDetails) ->
      new List.Layout
        collection: ieDetails

    showPanel: (ieDetails) ->
      panelView = @getPanelView ieDetails
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (ieDetails) ->
      new List.Panel
        collection: ieDetails

    showList: (ieDetails) ->
      listView = @getListView ieDetails

      @show listView,
        region: @layout.listRegion

    getListView: (ieDetails) ->
      new List.IEDetails
        collection: ieDetails