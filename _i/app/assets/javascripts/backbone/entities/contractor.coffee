@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Contractor extends Entities.Model
    idAttribute: 'idContractor'
    urlRoot: App.getServer() + '/contractors'

    initialize: ->
      new Backbone.Chooser(@)

    defaults:
      idUser: null
      idContractor: null
      name: ''
      note: ''

    parse: (response, options)->
      if not _.isUndefined response.contractor
        response = response.contractor
      response


  class Entities.Contractors extends Entities.Collection

    model: Entities.Contractor
    url: 'contractors'
    parse: (response, options)->
      response.contractors

    initialize: ->
      new Backbone.MultiChooser(@)

      @.on 'change:name', (model) =>
        @sort()

    comparator: (contractor) ->
      contractor.get('name')

  API =
    newContractorEntity: ->
      new Entities.Contractor

    getContractorEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.contractors
        App.entities.contractors = new Entities.Contractors
        force = true

      contractors = App.entities.contractors

      if force
        contractors.fetch
          reset: true
      contractors


  App.reqres.setHandler 'contractor:new:entity', ->
    API.newContractorEntity()

  App.reqres.setHandler 'contractor:entities', (options)->
    API.getContractorEntities(options)
