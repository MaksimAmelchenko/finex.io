@CashFlow.module 'MenuApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'menu/list/layout'

    regions:
      listRegion: '[name=list-region]'
      projectRegion: '[name=project-region]'

    ui:
      btnMinify: '.minifyme'
      btnFeedBack: '.btn-feedback'
      userName: '[name=userName]'

    events:
      'click @ui.btnMinify': 'minify'
      'click @ui.btnFeedBack': ->
        UE.Popin.show()
      'mouseover @ui.btnFeedBack': ->
        UE.Popin.preload()


    minify: (e) ->
      e.preventDefault()

      $('body')
      .toggleClass 'minified'
      .removeClass 'hidden-menu'

      $('html').removeClass 'hidden-menu-mobile-lock'

    onRender: ->
      @ui.userName.html App.entities.profile.get('name')


  #  The recursive tree view
  class List.Item extends App.Views.ItemView
    template: 'menu/list/_item'
    tagName: 'li'

    modelEvents:
      'change': 'render'

    events:
      'click': ->
        # TODO при частых кликах проблемы с отменой
        # App.xhrAbortAll()
        if App.MenuApp.prevMenuItem.id isnt @model.id
          App.MenuApp.prevMenuItem.unchoose()
          @model.choose()
          App.MenuApp.prevMenuItem = @model

    onRender: ->
      # TODO убрать мерцание: сначало становится оранжевым, а потом "серым", т.к. срабатыает :hover
      @$el.toggleClass('active', @model.isChosen())


  class List.Group extends App.Views.CompositeView
    template: 'menu/list/_group'
    tagName: 'li',
    childViewContainer: 'ul'

    getChildView: (model) ->
      if model.items then List.Group else List.Item

    initialize: ->
      # grab the child collection from the parent model
      # so that we can render the collection as children
      # of this parent node
      @collection = @model.items

  # The tree's root: a simple collection view that renders
  # a recursive tree structure for each item in the collection
  class List.Menu extends App.Views.CompositeView
    template: 'menu/list/menu'

    getChildView: (model) ->
      if model.items then List.Group else List.Item

    childViewContainer: 'ul'
    tagName: 'nav'

    onRender: ->
      App.MenuApp.prevMenuItem = @collection.getMenuItem('#' + App.getCurrentRoute(), 'url')
      App.MenuApp.prevMenuItem.choose()

      @$('ul').jarvismenu({
        accordion: false,
        speed: 235,
        closedSign: '<em class="fa fa-plus-square-o"></em>',
        openedSign: '<em class="fa fa-minus-square-o"></em>'
      })

  class List.Project extends App.Views.ItemView
    template: 'menu/list/_project'

    collectionEvents:
      'add change:name remove reset': 'render'

    events:
      'click li > a': (e) ->
        idProject = Number $(e.currentTarget).parent().data('idProject')
        App.execute 'use:project', idProject if idProject isnt App.request 'active:project'
        e.preventDefault()

    initialize: ->
      App.vent.on 'change:active:project', =>
        @render()
