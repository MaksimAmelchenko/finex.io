@CashFlow.module 'ReferencesTagsApp', (ReferencesTagsApp, App, Backbone, Marionette, $, _) ->
  class ReferencesTagsApp.Router extends Marionette.AppRouter
    appRoutes:
      'references/tags': 'list'

    before: ->
#      App.vent.trigger 'nav:main:choose', 'references'

  API =
    list: ->
      ReferencesTagsApp.list()

  App.addInitializer ->
    new ReferencesTagsApp.Router
      controller: API

  @list = (region, tag) ->
    new ReferencesTagsApp.List.Controller
      tag: tag


  @edit = (tag, region) ->
    new ReferencesTagsApp.Edit.Controller
      tag: tag
      region: region

  # -- Exchange Edit ----------------------


  App.reqres.setHandler 'tag:edit', (tag, region = App.request 'dialog:region') ->
    isNew = tag.isNew()
    editController = ReferencesTagsApp.edit tag, region

    editController.on 'form:after:save', (model) ->
      if isNew
        tags = App.request 'tag:entities'
        tags.add model
        tags.chooseNone()
        tags.choose model
      editController.form.formLayout.trigger 'dialog:close'

    editController

