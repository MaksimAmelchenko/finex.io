@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.DebtDetail extends Entities.Model
    idAttribute: 'idDebtDetail'
    defaults:
      idDebtDetail: null
      idUser: null
      sign: null
      dDebtDetail: null
      reportPeriod: null
      idAccount: null
      idCategory: null
      sum: null
      idCurrency: null
      note: null
      tags: []

    initialize: ->
      new Backbone.Chooser(@)

  #-----------------------------------------------------------------------

  class Entities.DebtDetails extends Entities.Collection
    model: Entities.DebtDetail

    initialize: ->
      new Backbone.MultiChooser(@)
      @on 'change:dDebtDetail', =>
        @sort()

#    comparator: (debtDetail) ->
#      -Date.parseExact(debtDetail.get('dDebtDetail'), 'yyyy-MM-dd').getTime()
    comparator: (debtDetail1, debtDetail2) ->
      dDebtDetail1 = moment(debtDetail1.get('dDebtDetail'), 'YYYY-MM-DD').toDate().getTime()
      dDebtDetail2 = moment(debtDetail2.get('dDebtDetail'), 'YYYY-MM-DD').toDate().getTime()
      if dDebtDetail1 > dDebtDetail2
        -1
      else
        if dDebtDetail1 < dDebtDetail2
          1
        else
          if debtDetail1.id and debtDetail2.id and debtDetail1.id > debtDetail2.id
            -1
          else
            if debtDetail1.id and debtDetail2.id and debtDetail1.id < debtDetail2.id
              1
            else
              if debtDetail1.cid > debtDetail2.cid
                -1
              else
                if debtDetail1.cid < debtDetail2.cid
                  1
                else
                  0

    parse: (response, options)->
      response.debtDetails

  API =
    newDebtDetailEntity: ->
      new Entities.DebtDetail
        sign: -1
#        idCategory: 2
        dDebtDetail: App.request 'default:date'
        reportPeriod: App.request 'default:reportPeriod'
        idMoney: (App.request 'default:money')?.get('idMoney')



  App.reqres.setHandler 'debt:detail:new:entity', ->
    API.newDebtDetailEntity()


