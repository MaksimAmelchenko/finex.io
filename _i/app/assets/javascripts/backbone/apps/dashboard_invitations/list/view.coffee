@CashFlow.module 'DashboardInvitationsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'dashboard_invitations/list/layout'
#    getTemplate: ->
#      if @collection.length is 0 then false else 'dashboard_invitations/list/layout'

    regions:
      listRegion: '[name=list-region]'

  #-----------------------------------------------------------------------

  class List.Invitation extends App.Views.ItemView
    template: 'dashboard_invitations/list/_invitation'
    tagName: 'div'
    className: 'well well-sm clearfix no-border'
#    className: 'padding-5'
    ui:
      btnAccept: '.btn[name=btnAccept]'
      btnReject: '.btn[name=btnReject]'

    events:
      'click @ui.btnAccept': 'accept'
      'click @ui.btnReject': 'reject'

    accept: ->
      App.xhrRequest
        type: 'PUT'
        url: "invitations/#{@model.id}/accept"
        success: (res, textStatus, jqXHR) =>
          @model.collection.remove @model
          App.request 'user:entities',
            force: true

    reject: ->
      App.xhrRequest
        type: 'PUT'
        url: "invitations/#{@model.id}/reject"
        success: (res, textStatus, jqXHR) =>
          @model.collection.remove @model

  #    events:
  #
  #    onRender: ->
  #-----------------------------------------------------------------------

  class List.Empty extends App.Views.ItemView
    template: 'dashboard_invitations/list/_empty'

  class List.Invitations extends App.Views.CompositeView
    getTemplate: ->
      if @collection.length is 0 then 'dashboard_invitations/list/_empty' else 'dashboard_invitations/list/_invitations'

    childView: List.Invitation
    childViewContainer: '.panel-body'

    collectionEvents:
      'remove': 'render'

