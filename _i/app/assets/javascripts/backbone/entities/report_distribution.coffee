@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.ReportDistribution extends Entities.Model
    urlRoot: App.getServer() + '/reports/distribution'

    defaults:
      items: []

    initialize: ->
      @isShowParams = false
      # 1 - expenditure, 2 - incomings, 3 - cost: max(expenditure - incomings, 0)
      @valueType = 3
      # 1 - table, 2 - graph
      @viewType = 1

      @cache = {}
      @params =
#        dBegin: moment().add(-5, 'months').startOf('month').add(-1, 'y').format('YYYY-MM-DD')
#        dEnd: moment().endOf('month').add(-1, 'y').format('YYYY-MM-DD')
        dBegin: moment().add(-12, 'months').startOf('month').format('YYYY-MM-DD')
        dEnd: moment().endOf('month').format('YYYY-MM-DD')
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

      @resetParams()


    makeCache: (items) ->
      _.each items, (item) =>
        @cache[item.idCategory] = item
        @makeCache item.items


    parse: (response, options)->
      # for fast access to node
      @cache = {}
      @makeCache(response.items)

      response

    resetParams: ->
      # exclude debts, transfers and exchanges
      categories = []
      App.entities.categories.forEach (category) ->
        if category.get('idCategoryPrototype') in [1, 20, 10]
          categories.push(category.get('idCategory'))


      @params.idMoney = (App.request 'default:money')?.get('idMoney')
      @params.contractors = []
      @params.categories = categories
      @params.tags = []


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
