@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.PlanCashFlowItem extends Entities.Model
    idAttribute: 'idPlanCashFlowItem'

    defaults:
      idUser: null
      idPlanCashFlowItem: null
      idContractor: null
      idAccount: null
      idCategory: null
      idMoney: null
      idUnit: null
      sign: null
      dBegin: null
      reportPeriod: null
      quantity: null
      sum: null
      note: ''
      tags: []
      repeatType: null
      repeatRate: null
      repeatDays: null
      endType: null
      reportCount: null
      dEnd: null

    urlRoot: App.getServer() + '/plans/cashflow_items'

    initialize: ->
      new Backbone.Chooser(@)

    parse: (response, options)->
      if not _.isUndefined response.planCashFlowItem
        response = response.planCashFlowItem
      response

    getSchedule: ->
      days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
      result = ''
      # @formatter:off
      switch @get('repeatType')
        when 1
          d = _.map @get('repeatDays'), (day) ->
            days[day-1]

          result =
            "
            Каждую #{if @get('repeatRate') is 1 then '' else '<strong>' + @get('repeatRate') + '</strong> '}
            неделю в <strong>#{d.join(', ')}</strong>.
            "
        when 2
          result =
            "
            Каждый #{if @get('repeatRate') is 1 then '' else '<strong>' + @get('repeatRate') + '</strong> '}
            месяц <strong>#{@get('repeatDays').join(', ')}</strong> числа.
            "
        when 3
          result =
            "
            Каждый год <strong>#{moment(@get('dBegin'), 'YYYY-MM-DD').format('DD MMMM')}</strong>
            "
      # @formatter:on

      if @get('endType') is 1
        result = result + ' Закончить после ' + @get('repeatCount') + 'выполнений.'
      else
        if @get('endType') is 2
          result = result + ' Закончить ' + moment(@get('dEnd'), 'YYYY-MM-DD').format('DD.MM.YYYY')

      result


  #---------------------------------------------------------------------------------

  class Entities.PlanCashFlowItems extends Entities.Collection
    model: Entities.PlanCashFlowItem
    url: 'plans/cashflow_items'

    initialize: ->
      new Backbone.MultiChooser(@)
      @.on 'model:change', =>
        @sort()

#    comparator: (cashFlowItem1, cashFlowItem2) ->
#      0

    parse: (response, options)->
      @total = response.metadata.total
      @limit = response.metadata.limit
      @offset = response.metadata.offset
      response.planCashFlowItems

    data: ->
      result =
        limit: @limit
        offset: @offset
      result

  API =
    newPlanCashFlowItemEntity: ->
      new Entities.PlanCashFlowItem
        idMoney: (App.request 'default:money')?.get('idMoney')
        sign: -1
        dBegin: App.request 'default:date'
        reportPeriod: App.request 'default:reportPeriod'
        repeatType: 0

    getPlanCashFlowItemEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.planCashFlowItems
        App.entities.planCashFlowItems = new Entities.PlanCashFlowItems()
        force = true

      planCashFlowItems = App.entities.planCashFlowItems

      if planCashFlowItems.length is 0
        force = true

      if force
        selected = planCashFlowItems.getChosen()
        planCashFlowItems.fetch
          reset: true
          success: ->
            planCashFlowItems.chooseByIds selected

      planCashFlowItems

  App.reqres.setHandler 'plan:cashFlowItem:new:entity', ->
    API.newPlanCashFlowItemEntity()

  App.reqres.setHandler 'plan:cashFlowItem:entities', (options)->
    API.getPlanCashFlowItemEntities(options)
