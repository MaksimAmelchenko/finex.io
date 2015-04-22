@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Unit extends Entities.Model
    idAttribute: 'idUnit'
    urlRoot: App.getServer() + '/units'

    initialize: ->
      new Backbone.Chooser(@)

    defaults:
      idUser: null
      idUnit: null
      name: ''

    parse: (response, options)->
      if not _.isUndefined response.unit
        response = response.unit
      response

  class Entities.Units extends Entities.Collection

    model: Entities.Unit
    url: 'units'
    parse: (response, options)->
      response.units

    initialize: ->
      new Backbone.MultiChooser(@)
      @.on 'change:name', =>
        @sort()

    comparator: (unit) ->
      unit.get('name')

  API =
    newUnitEntity: ->
      new Entities.Unit

    getUnitEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.units
        App.entities.units = new Entities.Units
        force = true

      units = App.entities.units

      if force
        units.fetch
          reset: true
      units


  App.reqres.setHandler 'unit:new:entity', ->
    API.newUnitEntity()

  App.reqres.setHandler 'unit:entities', (options)->
    API.getUnitEntities(options)
