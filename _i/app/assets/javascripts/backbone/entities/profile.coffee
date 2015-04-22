@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Profile extends Entities.Model
    urlRoot: App.getServer() + '/profile'
    idAttribute: 'idUser'

    defaults:
      idUser: null
      name: ''
      email: ''
      idProject: null
      currencyRateSource: null

    parse: (response, options)->
      response.profile

