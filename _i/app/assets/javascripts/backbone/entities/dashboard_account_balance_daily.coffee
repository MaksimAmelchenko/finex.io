@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.DashboardAccountsBalancesDaily extends Entities.Model
    urlRoot: App.getServer() + '/accounts/balances/daily'

    initialize: ->
      @params =
        dBegin: moment().subtract(12, 'months').format('YYYY-MM-DD')
        dEnd: moment().add(6, 'months').format('YYYY-MM-DD')
#        currency: App.request 'default:currency'
        idMoney: null
#        accountsUsingType: 1
#        accounts: []

#    parse: (response, options)->
#      response

    data: ->
      dBegin: @params.dBegin
      dEnd: @params.dEnd
      idMoney: @params.idMoney
#      accountsUsingType: @params.accountsUsingType
#      accounts: @params.accounts.toString()
