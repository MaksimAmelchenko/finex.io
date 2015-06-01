@CashFlow.module 'PlansCashFlowItemsApp', (PlansCashFlowItemsApp, App, Backbone, Marionette, $, _) ->
  API =
    list: (region) ->
      new PlansCashFlowItemsApp.List.Controller
        region: region

  App.commands.setHandler 'plans:cashFlowItems', (region) ->
    API.list region


  @edit = (model, region, config) ->
    new PlansCashFlowItemsApp.Edit.Controller
      model: model
      region: region
      config: config

  App.reqres.setHandler 'plan:cashFlowItem:edit', (model, collection, config = {}) ->
    isNew = model.isNew()

    _.defaults config,
      focusField: if isNew then 'account' else 'sum'

    editController = PlansCashFlowItemsApp.edit(model, App.request('dialog:region'), config)

    editController.on 'form:after:save', (model, options) ->
      if isNew
        collection.add model
        collection.chooseNone()
        collection.choose model

      editController.form.formLayout.trigger 'dialog:close'
