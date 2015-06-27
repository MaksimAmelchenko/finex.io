@CashFlow.module 'PlansExchangesApp', (PlansExchangesApp, App, Backbone, Marionette, $, _) ->
  API =
    list: (region) ->
      new PlansExchangesApp.List.Controller
        region: region

  App.commands.setHandler 'plans:exchanges', (region) ->
    API.list region


  @edit = (model, region, config) ->
    new PlansExchangesApp.Edit.Controller
      model: model
      region: region
      config: config

  App.reqres.setHandler 'plan:exchange:edit', (model, collection, config = {}) ->
    isNew = model.isNew()

    _.defaults config,
      focusField: if isNew then 'accountFrom' else 'sumFrom'

    editController = PlansExchangesApp.edit(model, App.request('dialog:region'), config)

    editController.on 'form:after:save', (model, options) ->
      if isNew
        collection.add model
        collection.chooseNone()
        collection.choose model

      editController.form.formLayout.trigger 'dialog:close'
