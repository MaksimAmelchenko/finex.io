@CashFlow.module 'CashFlowsDebtsApp', (CashFlowsDebtsApp, App, Backbone, Marionette, $, _) ->
  class CashFlowsDebtsApp.Router extends Marionette.AppRouter
    appRoutes:
      'cashflows/debts': 'list'

  API =
    list: (options = {})->
      CashFlowsDebtsApp.list options

  App.addInitializer ->
    new CashFlowsDebtsApp.Router
      controller: API

  @list = (options = {})->
    _.defaults options,
      force: true

    new CashFlowsDebtsApp.List.Controller options

  @edit = (debt, region) ->
    new CashFlowsDebtsApp.Edit.Controller
      debt: debt
      region: region

  @editDetail = (detail, region, config) ->
    new CashFlowsDebtsApp.EditDetail.Controller
      detail: detail
      region: region
      config: config

  App.vent.on 'nav:cashflows:choose:debts', (region) ->
    App.navigate 'cashflows/debts'
    CashFlowsDebtsApp.list region

  #-----------------------------------------
  App.reqres.setHandler 'debt:edit', (debt, region) ->
    isNew = debt.isNew()

    editController = CashFlowsDebtsApp.edit debt, region

    editController.on 'form:after:save', (model) ->
      if isNew
        debts = App.request 'debt:entities'
        debts.add model
        debts.chooseNone()
        debts.choose debt

      API.list
        force: false

    editController.on 'form:cancel', ->
      API.list
        force: false

  #-----------------------------------------
  App.reqres.setHandler 'debt:detail:edit', (detail, details, config = {}) ->
    isNew = detail.isNew()

    _.defaults config,
      focusField: if isNew then 'account' else 'sum'

    editController = CashFlowsDebtsApp.editDetail(detail, App.request('dialog:region'), config)

    editController.on 'form:after:save', (detail) ->
      if isNew and details
        details.add detail
        details.chooseNone()
        details.choose detail

      editController.form.formLayout.trigger 'dialog:close'

