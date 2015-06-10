@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.User extends Entities.Model
    idAttribute: 'idUser'
    urlRoot: App.getServer() + '/users'

#    initialize: ->
#      new Backbone.Chooser(@)

    defaults:
      idUser: null
      name: ''
      email: ''

    parse: (response, options)->
      if not _.isUndefined response.user
        response = response.user
      response

  class Entities.Users extends Entities.Collection
    model: Entities.User
    url: 'users'
    parse: (response, options)->
      response.users

    comparator: (user) ->
      user.get('name')

  API =
    getUserEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.users
        App.entities.users = new Entities.Users
        force = true

      users = App.entities.users

      if force
        users.fetch
          reset: true
      users


  App.reqres.setHandler 'user:entities', (options)->
    API.getUserEntities(options)
