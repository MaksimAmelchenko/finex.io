@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Category extends Entities.Model
    idAttribute: 'idCategory'

    urlRoot: App.getServer() + '/categories'

    initialize: ->
      new Backbone.Chooser(@)

    defaults:
      idCategory: null
      idUser: null
      parent: null
      name: ''
      isEnabled: true
      idUnit: null
      idCategoryPrototype: null
      note: ''

    # сильно проседает производительность JSON (c 30 до 70 мс), поэтому эти мутаторы уберем
    #    mutators:
    #      fullPath: ->
    #        @path true
    #      path: ->
    #        @path false

    parse: (response, options)->
      if not _.isUndefined response.category
        response = response.category
      response

    # get a top level of category
    topLevel: ->
      item = @
      categories = @collection
      idParent = item.get('parent')
      while  not _.isNull(idParent)
        item = categories.get(idParent)
        idParent = item.get('parent')
      item

    fullPath: ->
      @path true

    path: (isFull = false) ->
      if isFull then path = _.escape(@get('name')) else path = ''
      categories = @collection

      idParent = @get('parent')
      #      level = 0
      while  not _.isNull(idParent)
        parent = categories.get(idParent)
        path = _.escape(parent.get('name')) + if path then ' &rarr; ' + path else ''
        #        path = s.escapeHTML(parent.get('name')) + if path then ' > ' + path else ''
        idParent = parent.get('parent')
      #        level = level + 1

      #      _.repeat('&nbsp;', level * 3) + path
      path

  #    path_: ->
  #      path = []
  #      path.push @get('idCategory')
  #
  #      categories = @collection || CashFlow.entities.categories
  #
  #      idParent = @get('parent')
  #      while  not _.isNull(idParent)
  #        parent = categories.get(idParent)
  #        path.push parent.get('idCategory')
  #        idParent = parent.get('parent')
  #      path.reverse()


  class Entities.Categories extends Entities.Collection
    model: Entities.Category
    url: 'categories'

    # system category 'Debt'
    #    _debtCategory: null

    parse: (response, options)->
      response.categories

    initialize: ->
      new Backbone.SingleChooser(@)
      @on 'change:parent change:name change:isEnabled', =>
        @sort()
      @on 'reset', =>
        @_debtCategory = @findWhere({idCategoryPrototype: 1}).get('idCategory')

    #    comparator: (category) ->
    #      category.path(true)

    comparator: (category1, category2) ->
      if category1.get('isEnabled') > category2.get('isEnabled')
        -1
      else
        if  category1.get('isEnabled') < category2.get('isEnabled')
          1
        else
          if category1.path(true) < category2.path(true)
            -1
          else
            1


    filterBy: (options = {})->
      _.defaults options,
        isEnabled: null
        isSystem: null
        parent: null
        without: null
        idCategory: null

      items = @
      items.filter (item) ->
        if not _.isNull(options.idCategory)
          if options.idCategory is item.id
            return true

        if not _.isNull(options.isEnabled)
          return false if item.get('isEnabled') isnt options.isEnabled

        if not _.isNull(options.isSystem)
          return false if  item.get('isSystem') isnt options.isSystem

        if not _.isNull(options.parent)
          result = false
          parent = item.get('parent')
          while not _.isNull(parent) and not result
            if parent is options.parent
              result = true
            else
              parent = items.get(parent).get('parent')
          return false if result is false

        if not _.isNull(options.without)
          return false if item.id is options.without
          parent = item.get('parent')
          result = true
          while not _.isNull(parent) and result
            if parent is options.without
              return false
            else
              parent = items.get(parent).get('parent')

        return true

  API =
    newCategoryEntity: ->
      new Entities.Category

    getCategoryEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.categories
        App.entities.categories = new Entities.Categories
        force = true

      categories = App.entities.categories

      if force
        categories.fetch
          reset: true
      categories


  App.reqres.setHandler 'category:new:entity', ->
    API.newCategoryEntity()

  App.reqres.setHandler 'category:entities', (options)->
    API.getCategoryEntities(options)

  App.reqres.setHandler 'category:filtered:entities', (options = {})->
    App.entities.categories.filterBy options

  App.reqres.setHandler 'category:debt:entities', ->
    App.request 'category:filtered:entities',
      parent: App.entities.categories._debtCategory


  @categoryMatcher = (term, text, opt) ->
    # удаляем стрелку и множественные пробелы
    s = text.replace(/&rarr;/g, '').replace(/\s{2,}/g, ' ')
    _.trim(s).toUpperCase().indexOf(term.toUpperCase()) >= 0
