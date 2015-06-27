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
      repeatType: null
    #      repeatRate: null
      repeatDays: null
      endType: null
      reportCount: null
      dEnd: null
      operationNote: ''
      operationTags: []
      colorMark: null

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
      dBegin = moment(@get('dBegin'), 'YYYY-MM-DD')
      month = dBegin.month() + 1
      switch @get('repeatType')
        when 1
          d = _.map @get('repeatDays'), (day) ->
            days[day - 1]

          result =
            "
            Еженедельно в <strong>#{d.join(', ')}</strong>.
            "
        when 2
          result =
            "
            Ежемесячно <strong>#{@get('repeatDays').join(', ')}</strong> числа.
            "
        when 3
          result =
            "
            Ежеквартально <strong>#{dBegin.format('DD')}</strong> числа
            <strong>#{(month - Math.trunc((month - 1) / 3) * 3)}-го</strong> месяца.
            "
        when 4
          result =
            "
            Ежегодно <strong>#{dBegin.format('DD MMMM')}</strong>.
            "

      switch @get('endType')
        when 1
          result += '<br>Закончить после <strong>' + @get('repeatCount') + '</strong> выполнений.'
        when 2
          result += '<br>Закончить <strong>' + moment(@get('dEnd'),
              'YYYY-MM-DD').format('DD.MM.YYYY') + '</strong>'

      result


  #---------------------------------------------------------------------------------

  class Entities.PlanCashFlowItems extends Entities.Collection
    model: Entities.PlanCashFlowItem
    url: 'plans/cashflow_items'

    initialize: ->
      new Backbone.MultiChooser(@)
      @on 'change:dPlan', =>
        @sort()

    comparator: (plan1, plan2) ->
      m1 = moment(plan1.get('dPlan'), 'YYYY-MM-DD')
      m2 = moment(plan2.get('dPlan'), 'YYYY-MM-DD')

      if m1.isValid() then e1 = m1.toDate().getTime() else e1 = 0
      if m2.isValid() then e2 = m2.toDate().getTime() else e2 = 0

      if e1 > 0 and e2 > 0
        if e1 > e2
          1
        else
          if e1 < e2
            -1
          else
            0
      else
        if e1 is 0 and e2 is 0
          dBegin1 = moment(plan1.get('dBegin'), 'YYYY-MM-DD').toDate().getTime()
          dBegin2 = moment(plan2.get('dBegin'), 'YYYY-MM-DD').toDate().getTime()
          if dBegin1 > dBegin2
            1
          else
            if dBegin1 < dBegin2
              -1
            else
              0
        else
          if e1 > 0
            -1
          else
            1

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
        colorMark: 'bg-color-green'

    getPlanCashFlowItemEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.planCashFlowItems
        App.entities.planCashFlowItems = new Entities.PlanCashFlowItems
          limit: 10

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
