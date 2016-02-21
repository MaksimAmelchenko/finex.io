@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.ReportDynamics extends Entities.Model
    urlRoot: App.getServer() + '/reports/dynamics'

    defaults:
      items: []

    initialize: ->
      @isShowParams = false
      # 1 - expenditure, 2 - incomings, 3 - cost: max(expenditure - incomings, 0)
      @valueType = 3
      # 1 - table, 2 - graph
      @viewType = 2

      @cache = {}


      @params =
        dBegin: App.params.dashboard.dBegin
        dEnd: App.params.dashboard.dEnd
        isUseReportPeriod: true
        idMoney: null
        contractorsUsingType: 1
        contractors: []
        accountsUsingType: 1
        accounts: []
        categoriesUsingType: 2
        categories: []
        tagsUsingType: 1
        tags: []
        isUsePlan: true

      @resetParams()


    resetParams: ->
      # exclude debts, transfers and exchanges
      categories = []
      App.entities.categories.forEach (category) ->
        if category.get('idCategoryPrototype') in [1, 20, 10]
          categories.push(category.get('idCategory'))


      @params.idMoney = (App.request 'default:money')?.get('idMoney')
      @params.contractors = []
      @params.accounts = []
      @params.categories = categories
      @params.tags = []


    makeCache: (items) ->
      _.each items, (item) =>
        @cache[item.idCategory] = item
        @makeCache item.items


    parse: (response, options)->
      # for fast access to node
      @cache = {}
      @makeCache(response.items)

      response

    getMonths: ->
      result = []
      dBegin = moment(@params.dBegin, 'YYYY-MM-DD').startOf('month')
      dEnd = moment(@params.dEnd, 'YYYY-MM-DD').startOf('month')

      if dBegin.toDate() <= dEnd.toDate()
        while dBegin.toDate() <= dEnd.toDate()
          result.push dBegin.format('YYYYMM')
          dBegin.add(1, 'months')
      result

    data: ->
      dBegin: @params.dBegin
      dEnd: @params.dEnd
      isUseReportPeriod: @params.isUseReportPeriod
      idMoney: @params.idMoney
      contractorsUsingType: @params.contractorsUsingType
      contractors: @params.contractors.toString()
      accountsUsingType: @params.accountsUsingType
      accounts: @params.accounts.toString()
      categoriesUsingType: @params.categoriesUsingType
      categories: @params.categories.toString()
      tagsUsingType: @params.tagsUsingType
      tags: @params.tags.toString()
      isUsePlan: @params.isUsePlan
