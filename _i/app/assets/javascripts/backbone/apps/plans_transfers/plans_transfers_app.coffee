@CashFlow.module 'PlansTransfersApp', (PlansTransfersApp, App, Backbone, Marionette, $, _) ->
  API =
    list: (region) ->
      new PlansTransfersApp.List.Controller
        region: region

  App.commands.setHandler 'plans:transfers', (region) ->
    API.list region


  @edit = (model, region, config) ->
    new PlansTransfersApp.Edit.Controller
      model: model
      region: region
      config: config

  App.reqres.setHandler 'plan:transfer:edit', (model, collection, config = {}) ->
    isNew = model.isNew()

    _.defaults config,
      focusField: if isNew then 'accountFrom' else 'sum'

    editController = PlansTransfersApp.edit(model, App.request('dialog:region'), config)

    editController.on 'form:after:save', (model, options) ->
      if isNew
        collection.add model
        collection.chooseNone()
        collection.choose model

      editController.form.formLayout.trigger 'dialog:close'
