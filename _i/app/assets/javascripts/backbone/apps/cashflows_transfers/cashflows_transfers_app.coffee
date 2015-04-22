@CashFlow.module 'CashFlowsTransfersApp', (CashFlowsTransfersApp, App, Backbone, Marionette, $, _) ->
  class CashFlowsTransfersApp.Router extends Marionette.AppRouter
    appRoutes:
      'cashflows/transfers': 'list'

  API =
    list: (options = {}) ->
      CashFlowsTransfersApp.list options

  App.addInitializer ->
    new CashFlowsTransfersApp.Router
      controller: API

  @list = (options = {})->
    _.defaults options,
      force: true

    new CashFlowsTransfersApp.List.Controller options


  @edit = (transfer, region, config) ->
    new CashFlowsTransfersApp.Edit.Controller
      transfer: transfer
      region: region
      config: config

  # -- Transfer Edit ----------------------
  App.reqres.setHandler 'transfer:edit', (transfer, transfers, config = {}) ->
    isNew = transfer.isNew()

    _.defaults config,
      focusField: if isNew then 'accountFrom' else 'sum'

    editController = CashFlowsTransfersApp.edit(transfer, App.request('dialog:region'), config)

    editController.on 'form:after:save', (transfer) ->
      if isNew and transfers
        transfers.add transfer
        transfers.chooseNone()
        transfers.choose transfer

      editController.form.formLayout.trigger 'dialog:close'

