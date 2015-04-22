@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.DashboardBalances extends Entities.Model
    urlRoot: App.getServer() + '/dashboard/balances'

    initialize: ->
      @params =
        dBalance: moment().format('YYYY-MM-DD')
        idMoney: null
        isShowZeroBalance: false

    data: ->
      dBalance: @params.dBalance
      idMoney: @params.idMoney