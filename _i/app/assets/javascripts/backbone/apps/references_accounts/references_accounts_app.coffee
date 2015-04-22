@CashFlow.module 'ReferencesAccountsApp', (ReferencesAccountsApp, App, Backbone, Marionette, $, _) ->
  class ReferencesAccountsApp.Router extends Marionette.AppRouter
    appRoutes:
      'references/accounts': 'list'

    before: ->
#      App.vent.trigger 'nav:main:choose', 'references'

  API =
    list: ->
#      App.execute 'references:list', 'accounts'
      ReferencesAccountsApp.list()

  App.addInitializer ->
    new ReferencesAccountsApp.Router
      controller: API

  @list = (region, account) ->
    new ReferencesAccountsApp.List.Controller
#        region: region
      account: account


  @edit = (account, region) ->
    new ReferencesAccountsApp.Edit.Controller
      account: account
      region: region

  # -- Exchange Edit ----------------------


  App.reqres.setHandler 'account:edit', (account, region = App.request 'dialog:region') ->
#  App.reqres.setHandler 'account:edit', (account, region) ->
    isNew = account.isNew()
    #    debugger
    editController = ReferencesAccountsApp.edit account, region

    editController.on 'form:after:save', (model) ->
      if isNew
        accounts = App.request 'account:entities'
        accounts.add model
        accounts.chooseNone()
        accounts.choose model
      editController.form.formLayout.trigger 'dialog:close'

    #    editController.on 'form:cancel', ->
    #      API.list()

    editController

#  App.vent.on 'nav:references:choose:accounts', (region) ->
#    App.navigate 'references/accounts'
#    ReferencesAccountsApp.list region

