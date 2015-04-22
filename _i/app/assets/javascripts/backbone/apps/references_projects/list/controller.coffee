@CashFlow.module 'ReferencesProjectsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {})->
      {project} = options
      projects = App.request 'project:entities'
      if project
#        projects.chooseNone()
        projects.choose project

      @layout = @getLayoutView projects
      @listenTo @layout, 'show', =>
        @showPanel projects
        @showList projects

      @show @layout,
        loading:
          entities: projects

    getLayoutView: (projects) ->
      new List.Layout
        collection: projects

    showPanel: (projects) ->
      panelView = @getPanelView projects
      @show panelView,
        region: @layout.panelRegion

    getPanelView: (projects) ->
      new List.Panel
        collection: projects

    showList: (projects) ->
      listView = @getListView projects

#      @listenTo listView, 'childview:project:clicked', (child, args) ->
#        {model} = args
#
#        #        model.collection.chooseNone()
#        model.choose()
#
#        #        App.request 'account:edit', model, @region
#        if model.get('permit') is 7
#          App.request 'project:edit', model

      @show listView,
        region: @layout.listRegion

    getListView: (projects) ->
      new List.Projects
        collection: projects
