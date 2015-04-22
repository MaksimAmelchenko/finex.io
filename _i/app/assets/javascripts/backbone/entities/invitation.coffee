@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Invitation extends Entities.Model
    idAttribute: 'idInvitation'

    defaults:
      idInvitation: null
      idUserHost: null
      emailHost: null
      message: ''


  class Entities.Invitations extends Entities.Collection
    model: Entities.Invitation

    comparator: (user) ->
      user.get('idInvitation')

  App.reqres.setHandler 'invitation:entities', (options)->
    App.entities.invitations
