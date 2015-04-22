@CashFlow.module 'ReferencesCategoriesApp', (ReferencesCategoriesApp, App, Backbone, Marionette, $, _) ->
  class ReferencesCategoriesApp.Router extends Marionette.AppRouter
    appRoutes:
      'references/categories': 'list'

#    before: ->
#      App.vent.trigger 'nav:main:choose', 'references'

  API =
    list: ->
      ReferencesCategoriesApp.list()

  App.addInitializer ->
    new ReferencesCategoriesApp.Router
      controller: API

  @list = (region, item) ->
    new ReferencesCategoriesApp.List.Controller
#        region: region
      item: item

  @edit = (item, region) ->
    new ReferencesCategoriesApp.Edit.Controller
      item: item
      region: region

  @move = (config, region) ->
    new ReferencesCategoriesApp.Move.Controller
      config: config
      region: region

  # -- Exchange Edit ----------------------


  App.reqres.setHandler 'category:edit', (item, region = App.request 'dialog:region') ->
    isNew = item.isNew()
    editController = ReferencesCategoriesApp.edit item, region

    editController.on 'form:after:save', (model) ->
      if isNew
        categories = App.request 'category:entities'
        categories.add model
        categories.choose model

      editController.form.formLayout.trigger 'dialog:close'
    editController

  # -----------------------------------------------------
  # config:
  # idCategoryFrom - из какой категории переносить
  App.reqres.setHandler 'category:move', (config, region = App.request 'dialog:region') ->
    moveController = ReferencesCategoriesApp.move config, region

    moveController.on 'form:after:save', ->
      moveController.form.formLayout.trigger 'dialog:close'

    moveController
