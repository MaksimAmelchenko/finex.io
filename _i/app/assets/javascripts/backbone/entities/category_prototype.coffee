@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.CategoryPrototype extends Entities.Model
    idAttribute: 'idCategoryPrototype'

    defaults:
      idCategoryPrototype: null
      name: ''
      parent: null

    parse: (response, options)->
      if not _.isUndefined response.categoryPrototype
        response = response.categoryPrototype
      response

    fullPath: ->
      @path true

    path: (isFull = false) ->
      if isFull then path = _.escape(@get('name')) else path = ''
      categoryPrototypes = @collection

      idParent = @get('parent')
      while  not _.isNull(idParent)
        parent = categoryPrototypes.get(idParent)
        path = _.escape(parent.get('name')) + if path then ' &rarr; ' + path else ''
        idParent = parent.get('parent')
      path

  class Entities.CategoryPrototypes extends Entities.Collection

    model: Entities.CategoryPrototype

    parse: (response, options)->
      response.categoryPrototypes

