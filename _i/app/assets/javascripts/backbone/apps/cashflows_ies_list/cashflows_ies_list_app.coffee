@CashFlow.module 'CashFlowsIEsListApp', (CashFlowsIEsListApp, App, Backbone, Marionette, $, _) ->
  class CashFlowsIEsListApp.Router extends Marionette.AppRouter
    appRoutes:
      'cashflows/ies/list': 'list'

  API =
    list: (options = {}) ->
      CashFlowsIEsListApp.list options

  App.addInitializer ->
    new CashFlowsIEsListApp.Router
      controller: API

  @list = (options = {})->
    _.defaults options,
      force: true

    new CashFlowsIEsListApp.List.Controller options


  @edit = (ie, region) ->
    new CashFlowsIEsListApp.Edit.Controller
      ie: ie
      region: region

  # -- IE Edit
  App.reqres.setHandler 'ie:edit', (ie, region) ->
    CashFlowsIEsListApp.edit ie, region


  App.reqres.setHandler 'ie:edit:ies_list', (ie, region) ->
    isNew = ie.isNew()

    editController = App.request 'ie:edit', ie, region

    editController.on 'form:after:save', (model) ->
      if isNew
        ies = App.request 'ie:entities'
        ies.add model
        ies.chooseNone()
        ies.choose ie

      API.list
        force: false

    editController.on 'form:cancel', ->
      API.list
        force: false

