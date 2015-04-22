@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.AccountType extends Entities.Model
    idAttribute: 'idAccountType'

    defaults:
      idAccountType: null
      name: ''
      shortName: ''


  class Entities.AccountTypes extends Entities.Collection
    model: Entities.AccountType
    parse: (response, options)->
      response.accountTypes
