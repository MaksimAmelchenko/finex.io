@CashFlow.module 'ReferencesContractorsApp', (ReferencesContractorsApp, App, Backbone, Marionette, $, _) ->
  class ReferencesContractorsApp.Router extends Marionette.AppRouter
    appRoutes:
      'references/contractors': 'list'

  API =
    list: ->
      ReferencesContractorsApp.list()

  App.addInitializer ->
    new ReferencesContractorsApp.Router
      controller: API

  @list = (region, contractor) ->
    new ReferencesContractorsApp.List.Controller
#      region: region
      contractor: contractor


  @edit = (contractor, region) ->
    new ReferencesContractorsApp.Edit.Controller
      contractor: contractor
      region: region

  # -- Exchange Edit ----------------------
  App.reqres.setHandler 'contractor:edit', (contractor, region = App.request 'dialog:region') ->
    isNew = contractor.isNew()
    editController = ReferencesContractorsApp.edit contractor, region

    editController.on 'form:after:save', (model) ->
      if isNew
        contractors = App.request 'contractor:entities'
        contractors.add model
        contractors.chooseNone()
        contractors.choose model
      editController.form.formLayout.trigger 'dialog:close'

    editController

