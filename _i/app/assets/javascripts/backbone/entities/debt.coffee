@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Debt extends Entities.Model
    idAttribute: 'idDebt'
    urlRoot: App.getServer() + '/cashflows/debts'
    initialize: ->
      new Backbone.Chooser(@)

    mutators:
      dDebt: ->
        debtDetail = _.max @get('debtDetails'), (debtDetail) ->
          moment(debtDetail.dDebtDetail, 'YYYY-MM-DD').toDate().getTime()
        if debtDetail.dDebtDetail
          debtDetail.dDebtDetail
        else
          if @get('dSet') then moment(@get('dSet'), 'YYYY-MM-DD HH:mm:ss').format('YYYY-MM-DD')

    defaults:
      idDebt: null
      idUser: null
      idContractor: null
      note: ''
      debtDetails: []
      dSet: null


    parse: (response, options)->
      if not _.isUndefined response.debt
        response = response.debt
      response

    getMoneys: ->
      App.Entities.sortListByMoney(_.uniq(_.pluck(@get('debtDetails'), 'idMoney')))

    getBalance: ->
      balance = {}

      _.each @get('debtDetails'), (detail) ->
        balance[detail.idMoney] ?= {}

        # @formatter:off
        switch App.entities.categories.get(detail.idCategory).get('idCategoryPrototype')
          when 2 then category = 'debt'
          when 3 then category = 'paidDebt'
          when 4 then category = 'paidInterest'
          when 5 then category = 'fine'
          when 6 then category = 'fee'
          else
            alert "Unknown 'idCategoryPrototype': #{detail.idCategory}"
        # @formatter:on

        balance[detail.idMoney][category] ?= 0
        balance[detail.idMoney][category] += detail.sign * detail.sum

      balance

  #-----------------------------------------------------------------------

  class Entities.Debts extends Entities.Collection

    model: Entities.Debt
    url: 'cashflows/debts'

    initialize: ->
      new Backbone.MultiChooser(@)
      @on 'change:debtDetails', =>
        @sort()

      @searchText = ''

      @isUseFilters = false
      @filters =
        dBegin: null
        dEnd: null
        isOnlyNotPaid: false
        contractors: []
        tags: []

    resetFilters: ->
      @filters.contractors = []
      @filters.tags = []

#    comparator: (debt) ->
#      -Date.parseExact(debt.get('dDebt'), 'yyyy-MM-dd').getTime()
    comparator: (debt1, debt2) ->
      dDebt1 = moment(debt1.get('dDebt'), 'YYYY-MM-DD').toDate().getTime()
      dDebt2 = moment(debt2.get('dDebt'), 'YYYY-MM-DD').toDate().getTime()
      if dDebt1 > dDebt2
        -1
      else
        if dDebt1 < dDebt2
          1
        else
          if debt1.id > debt2.id
            -1
          else
            if debt1.id < debt2.id
              1
            else
              0

    parse: (response, options)->
      @total = response.metadata.total
      @limit = response.metadata.limit
      @offset = response.metadata.offset
      response.debts

    data: ->
      result =
        limit: @limit
        offset: @offset
        searchText: @searchText
      if @isUseFilters
        result = $.extend result,
          dBegin: @filters.dBegin
          dEnd: @filters.dEnd
          isOnlyNotPaid: @filters.isOnlyNotPaid
          contractors: @filters.contractors.toString()
          tags: @filters.tags.toString()
      result

  API =
    newDebtEntity: ->
      new Entities.Debt
#        idCurrency: App.request 'default:currency'

    getDebtEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.debts
        App.entities.debts = new Entities.Debts
        force = true

      debts = App.entities.debts

      if force
        selected = debts.getChosen()
        debts.fetch
          reset: true
          success: ->
            debts.chooseByIds selected

      debts


  App.reqres.setHandler 'debt:new:entity', ->
    API.newDebtEntity()

  App.reqres.setHandler 'debt:entities', (options)->
    API.getDebtEntities(options)
