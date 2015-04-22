@CashFlow.module 'MenuApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'menu/list/layout'

    regions:
      listRegion: '[name=list-region]'

    ui:
      btnMinify: '.minifyme'
      btnFeedBack: '.feedback'
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

#    modelEvents:
#      'change:chosen': 'render'
    events:
      'click': ->
#        App.xhrAbortAll()

    onRender: ->
      if App.getCurrentRoute() is s.ltrim(@model.get('url'), '#')
        @$el.addClass 'active'


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
      @$('ul').jarvismenu({
        accordion: false,
        speed: 235,
        closedSign: '<em class="fa fa-plus-square-o"></em>',
        openedSign: '<em class="fa fa-minus-square-o"></em>'
      })


