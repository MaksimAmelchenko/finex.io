@CashFlow.module 'CashFlowsIEsDetailsApp', (CashFlowsIEsDetailsApp, App, Backbone, Marionette, $, _) ->
  class CashFlowsIEsDetailsApp.Router extends Marionette.AppRouter
    appRoutes:
      'cashflows/ies/details': 'list'

  API =
    list: (options = {}) ->
      CashFlowsIEsDetailsApp.list options

  App.addInitializer ->
    new CashFlowsIEsDetailsApp.Router
      controller: API

  @list = (options = {})->
    _.defaults options,
      force: true

    new CashFlowsIEsDetailsApp.List.Controller options


  @edit = (ieDetail, region, config) ->
    new CashFlowsIEsDetailsApp.Edit.Controller
      ieDetail: ieDetail
      region: region
      config: config


  App.reqres.setHandler 'ie:detail:edit', (ieDetail, ieDetails, config = {}) ->
    isNew = ieDetail.isNew()

    _.defaults config,
      focusField: if isNew and not ieDetail.get('idPlan') then 'account' else 'sum'
      isSync: true

    editController = CashFlowsIEsDetailsApp.edit(ieDetail, App.request('dialog:region'), config)

    editController.on 'form:after:save', (ieDetail, options) ->
      if isNew
        ieDetails.add ieDetail
        ieDetails.chooseNone()
        ieDetails.choose ieDetail
      if options?.isMore
        model = App.request 'ie:detail:new:entity'
        model.set
          sign: ieDetail.get 'sign'
          dIEDetail: ieDetail.get 'dIEDetail'
          reportPeriod: ieDetail.get 'reportPeriod'
          idAccount: ieDetail.get 'idAccount'
          idCategory: ieDetail.get 'idCategory'
          idUnit: ieDetail.get 'idUnit'
          idMoney: ieDetail.get 'idMoney'

        config.focusField = 'category'

        editController.form.formLayout.trigger 'dialog:close'
        App.request 'ie:detail:edit', model, ieDetails, config
      else
        editController.form.formLayout.trigger 'dialog:close'

  # Edit CashFlow from ies_detail
  App.reqres.setHandler 'ie:edit:ies_details', (ie, region, config = {}) ->
    editController = App.request 'ie:edit', ie, region

    editController.on 'form:after:save', (ie, options) ->
#      App.entities.ieDetails.fetch()
      API.list()

    editController.on 'form:cancel', ->
      API.list
        force: false

