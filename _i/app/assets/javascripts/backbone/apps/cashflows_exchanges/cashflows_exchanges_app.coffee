@CashFlow.module 'CashFlowsExchangesApp', (CashFlowsExchangesApp, App, Backbone, Marionette, $, _) ->
  class CashFlowsExchangesApp.Router extends Marionette.AppRouter
    appRoutes:
      'cashflows/exchanges': 'list'

  API =
    list: (options = {})->
      CashFlowsExchangesApp.list options

  App.addInitializer ->
    new CashFlowsExchangesApp.Router
      controller: API

  @list = (options = {})->
    _.defaults options,
      force: true
    new CashFlowsExchangesApp.List.Controller options

  @edit = (exchange, region, config) ->
    new CashFlowsExchangesApp.Edit.Controller
      exchange: exchange
      region: region
      config: config

  # -- Exchange Edit ----------------------
  App.reqres.setHandler 'exchange:edit', (exchange, exchanges, config = {}) ->
    isNew = exchange.isNew()

    _.defaults config,
      focusField: if isNew then 'accountFrom' else 'sumFrom'

    editController = CashFlowsExchangesApp.edit(exchange, App.request('dialog:region'), config)

    editController.on 'form:after:save', (model) ->
      if isNew and exchanges
        exchanges.add model
        exchanges.chooseNone()
        exchanges.choose model

      editController.form.formLayout.trigger 'dialog:close'
