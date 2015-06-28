@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.DashboardAccountsBalancesDaily extends Entities.Model
    urlRoot: App.getServer() + '/accounts/balances/daily'

    initialize: ->
      @params =
        dBegin: App.params.dashboard.dBegin
        dEnd: App.params.dashboard.dEnd
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

    resetParams: ->
      @params.dBegin = App.params.dashboard.dBegin
      @params.dEnd = App.params.dashboard.dEnd
