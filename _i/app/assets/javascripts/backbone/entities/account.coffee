@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Account extends Entities.Model
    idAttribute: 'idAccount'
    urlRoot: App.getServer() + '/accounts'

    initialize: ->
      new Backbone.Chooser(@)

    defaults:
      idUser: null
      idAccount: null
      idAccountType: null
      name: ''
      isEnabled: true
      readers: [],
      writers: [],
      note: ''

    parse: (response, options)->
      if not _.isUndefined response.account
        response = response.account
      response

  class Entities.Accounts extends Entities.Collection

    model: Entities.Account
    url: 'accounts'
    parse: (response, options)->
      response.accounts

    initialize: ->
      new Backbone.MultiChooser(@)
      @.on 'change:name', =>
        @sort()

    comparator: (account) ->
      account.get('name')


  API =
    newAccountEntity: ->
      new Entities.Account
        idAccountType: 1

    getAccountEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.accounts
        App.entities.accounts = new Entities.Accounts
        force = true

      accounts = App.entities.accounts

      if force
        accounts.fetch
          reset: true
      accounts

  App.reqres.setHandler 'account:new:entity', ->
    API.newAccountEntity()

  #  App.reqres.setHandler 'account:entity', (idAccount)  ->
  #    API.getAccountEntity idAccount

  App.reqres.setHandler 'account:entities', (options)->
    API.getAccountEntities(options)

  App.reqres.setHandler 'enabled:account:entities', (idAccount) ->
    App.entities.accounts.filter (item) ->
      return item.get('isEnabled') or item.id is idAccount
