@CashFlow.module 'CashFlowsIEsListApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {}) ->
      {ie, force} = options
      ies = App.request 'ie:entities',
        force: force
      if ie
        ies.chooseNone()
        ies.choose ie

      @layout = @getLayoutView ies
      @listenTo @layout, 'show', =>
        @showPanel ies
        @showIEs ies

      @show @layout,
        loading:
          entities: ies

    getLayoutView: (ies) ->
      new List.Layout
        collection: ies

    showPanel: (ies) ->
      panelView = @getPanelView ies
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (ies) ->
      new List.Panel
        collection: ies

    showIEs: (ies) ->
      iesView = @getIEsView ies

      @listenTo iesView, 'childview:ie:clicked', (child, args) ->
        {model} = args
        if not getSelection().toString()
          model.collection.chooseNone()
          model.choose()
          App.request 'ie:edit:ies_list', model, @region

      @show iesView,
        region: @layout.listRegion

    getIEsView: (ies) ->
      new List.IEs
        collection: ies
