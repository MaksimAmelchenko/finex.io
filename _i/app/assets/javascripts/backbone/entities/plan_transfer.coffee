@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.PlanTransfer extends Entities.Model
    idAttribute: 'idPlanTransfer'

    defaults:
      idUser: null
      idPlanTransfer: null
      idAccountFrom: null
      idAccountTo: null
      sum: null
      idMoney: null
      idAccountFee: null
      isFee: null
      fee: null
      idMoneyFee: null
      dBegin: null
      reportPeriod: null
      note: ''
      repeatType: null
      repeatDays: null
      endType: null
      reportCount: null
      dEnd: null
      operationNote: ''
      operationTags: []
      colorMark: null

    urlRoot: App.getServer() + '/plans/transfers'

    initialize: ->
      new Backbone.Chooser(@)

    parse: (response, options)->
      if not _.isUndefined response.planTransfer
        response = response.planTransfer
      response

    getSchedule: ->
      days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
      result = ''
      dBegin = moment(@get('dBegin'), 'YYYY-MM-DD')
      # @formatter:off
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
            Ежеквартально <strong>#{dBegin.format('DD')}</strong> числа <strong>#{((dBegin.month() + 1) % 3)+ 1}-го </strong> месяца.
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
          result += '<br>Закончить <strong>' + moment(@get('dEnd'), 'YYYY-MM-DD').format('DD.MM.YYYY') + '</strong>'
      # @formatter:on

      result

  # --------------------------------------------------------------------------------

  class Entities.PlanTransfers extends Entities.Collection
    model: Entities.PlanTransfer
    url: 'plans/transfers'

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
      response.planTransfers

    data: ->
      result =
        limit: @limit
        offset: @offset
      result

  API =
    newPlanTransferEntity: ->
      new Entities.PlanTransfer
        idMoney: (App.request 'default:money')?.get('idMoney')
#        idMoneyFee: (App.request 'default:money')?.get('idMoney')
        dBegin: App.request 'default:date'
        reportPeriod: App.request 'default:reportPeriod'
        isFee: false
        repeatType: 0
        colorMark: 'bg-color-green'

    getPlanTransferEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.planTransfers
        App.entities.planTransfers = new Entities.PlanTransfers()
        force = true

      planTransfers = App.entities.planTransfers

      if planTransfers.length is 0
        force = true

      if force
        selected = planTransfers.getChosen()
        planTransfers.fetch
          reset: true
          success: ->
            planTransfers.chooseByIds selected

      planTransfers

  App.reqres.setHandler 'plan:transfer:new:entity', ->
    API.newPlanTransferEntity()

  App.reqres.setHandler 'plan:transfer:entities', (options)->
    API.getPlanTransferEntities(options)
