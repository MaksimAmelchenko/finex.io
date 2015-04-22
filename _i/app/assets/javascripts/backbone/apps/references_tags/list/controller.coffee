@CashFlow.module 'ReferencesTagsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {})->
      {tag} = options
      tags = App.request 'tag:entities'
      if tag
        tags.chooseNone()
        tags.choose tag

      @layout = @getLayoutView tags
      @listenTo @layout, 'show', =>
        @showPanel tags
        @showList tags

      @show @layout,
        loading:
          entities: tags

    getLayoutView: (tags) ->
      new List.Layout
        collection: tags

    getPanelView: (tags) ->
      new List.Panel
        collection: tags

    showPanel: (tags) ->
      panelView = @getPanelView tags
      @show panelView,
        region: @layout.panelRegion

    showList: (tags) ->
      listView = @getListView tags

#      @listenTo listView, 'childview:tag:clicked', (child, args) ->
#        {model} = args
#
#        if model.get('idUser')
#          model.collection.chooseNone()
#          model.choose()
#
#          App.request 'tag:edit', model

      @show listView,
        region: @layout.listRegion

    getListView: (tags) ->
      new List.Tags
        collection: tags

