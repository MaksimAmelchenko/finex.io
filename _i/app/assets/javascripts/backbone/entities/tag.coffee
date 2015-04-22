@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Tag extends Entities.Model
    idAttribute: 'idTag'
    urlRoot: App.getServer() + '/tags'

    initialize: ->
      new Backbone.Chooser(@)

    defaults:
      idUser: null
      idTag: null
      name: ''

    parse: (response, options)->
      if not _.isUndefined response.tag
        response = response.tag
      response

  class Entities.Tags extends Entities.Collection

    model: Entities.Tag
    url: 'tags'
    parse: (response, options)->
      response.tags

    initialize: ->
      new Backbone.MultiChooser(@)
      @.on 'change:name', =>
        @sort()

    comparator: (tag) ->
      tag.get('name')

  API =
    newTagEntity: ->
      new Entities.Tag

    getTagEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.tags
        App.entities.tags = new Entities.Tags
        force = true

      tags = App.entities.tags

      if force
        tags.fetch
          reset: true
      tags


  App.reqres.setHandler 'tag:new:entity', ->
    API.newTagEntity()

  App.reqres.setHandler 'tag:entities', (options)->
    API.getTagEntities(options)
