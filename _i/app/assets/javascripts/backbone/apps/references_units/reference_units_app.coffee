@CashFlow.module 'ReferencesUnitsApp', (ReferencesUnitsApp, App, Backbone, Marionette, $, _) ->
  class ReferencesUnitsApp.Router extends Marionette.AppRouter
    appRoutes:
      'references/units': 'list'

    before: ->
#      App.vent.trigger 'nav:main:choose', 'references'

  API =
    list: ->
      ReferencesUnitsApp.list()

  App.addInitializer ->
    new ReferencesUnitsApp.Router
      controller: API

  @list = (region, unit) ->
    new ReferencesUnitsApp.List.Controller
      unit: unit


  @edit = (unit, region) ->
    new ReferencesUnitsApp.Edit.Controller
      unit: unit
      region: region

  # -- Exchange Edit ----------------------


  App.reqres.setHandler 'unit:edit', (unit, region = App.request 'dialog:region') ->
    isNew = unit.isNew()
    editController = ReferencesUnitsApp.edit unit, region

    editController.on 'form:after:save', (model) ->
      if isNew
        units = App.request 'unit:entities'
        units.add model
        units.chooseNone()
        units.choose model
      editController.form.formLayout.trigger 'dialog:close'

    editController


#  App.vent.on 'nav:references:choose:units', (region) ->
#    App.navigate 'references/units'
#    ReferencesUnitsApp.list region

