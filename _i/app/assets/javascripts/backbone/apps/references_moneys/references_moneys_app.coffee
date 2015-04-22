@CashFlow.module 'ReferencesMoneysApp', (ReferencesMoneysApp, App, Backbone, Marionette, $, _) ->
  class ReferencesMoneysApp.Router extends Marionette.AppRouter
    appRoutes:
      'references/moneys': 'list'

  #    before: ->
  #      App.vent.trigger 'nav:main:choose', 'references'

  API =
    list: ->
      ReferencesMoneysApp.list()

  App.addInitializer ->
    new ReferencesMoneysApp.Router
      controller: API

  @list = (region, money) ->
    new ReferencesMoneysApp.List.Controller
#        region: region
      money: money


  @edit = (money, region) ->
    new ReferencesMoneysApp.Edit.Controller
      money: money
      region: region

  # --  Edit ----------------------
  App.reqres.setHandler 'money:edit', (money, region = App.request 'dialog:region') ->
    isNew = money.isNew()
    editController = ReferencesMoneysApp.edit money, region

    editController.on 'form:after:save', (model) ->
      if isNew
        moneys = App.request 'money:entities'
        moneys.add model
        moneys.chooseNone()
        moneys.choose model
      editController.form.formLayout.trigger 'dialog:close'

    #    editController.on 'form:cancel', ->
    #      API.list()

    editController

