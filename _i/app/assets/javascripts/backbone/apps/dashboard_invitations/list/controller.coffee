@CashFlow.module 'DashboardInvitationsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Controller extends App.Controllers.Application
    initialize: (options = {})->
      invitations = App.entities.invitations

      @layout = @getLayoutView invitations
      @listenTo @layout, 'show', =>
        @showList invitations

      @show @layout

    getLayoutView: (invitations) ->
      new List.Layout
        collection: invitations


    showList: (invitations) ->
      listView = @getListView invitations

      @show listView,
        region: @layout.listRegion
#        forceShow: true

    getListView: (invitations) ->
      new List.Invitations
        collection: invitations

