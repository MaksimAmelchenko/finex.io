@CashFlow.module 'ReferencesTagsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'references_tags/list/layout'

    regions:
      panelRegion: '[name=panel-region]'
      listRegion: '[name=list-region]'

    collectionEvents:
      'sync:start': 'syncStart'
      'sync:stop': 'syncStop'

    syncStart: (entity) ->
      # triggered for deleting of model too, so just check
      if entity is @collection
        @addOpacityWrapper()

    syncStop: ->
      @addOpacityWrapper(false)

    onDestroy: ->
      @addOpacityWrapper(false)

  #-----------------------------------------------------------------------

  class List.Panel extends App.Views.ItemView
    template: 'references_tags/list/_panel'
    className: 'container-fluid'

    ui:
      btnAdd: '.btn[name=btnAdd]'
      btnDel: '.btn[name=btnDel]'
      btnRefresh: '.btn[name=btnRefresh]'

    initialize: ->
      @listenTo @collection, 'collection:chose:none', =>
        @ui.btnDel.amkDisable()

      @listenTo @collection, 'collection:chose:some collection:chose:all', =>
        @ui.btnDel.amkEnable()

    events:
      'click @ui.btnAdd': 'add'
      'click @ui.btnDel': 'del'
      'click @ui.btnRefresh': 'refresh'

    collectionEvents:
      'sync': 'render'

    add: ->
      model = App.request 'tag:new:entity'
      App.request 'tag:edit', model

    del: ->
      model.destroy()  for model in  @collection.getChosen()

    refresh: ->
      App.request 'tag:entities',
        force: true

    onRender: ->
      @ui.btnDel.amkDisable() if @collection.getChosen().length is 0

  #-----------------------------------------------------------------------

  class List.Tag extends App.Views.ItemView
    template: 'references_tags/list/_tag'
    tagName: 'tr'

#    triggers:
#      'click': 'tag:clicked'

    modelEvents:
      'change': 'render'

    ui:
      tickbox: 'td:first-child'

    events:
      'click': (e) ->
        e.stopPropagation()
        @model.toggleChoose() unless getSelection().toString()

      'click a': ->
        App.request 'tag:edit', @model
        false

#    initialize: ->

    onRender: ->
      isChosen = @model.isChosen()
      @$el.toggleClass('info', isChosen)
      $('i', @ui.tickbox).toggleClass('fa-square-o', !isChosen).toggleClass('fa-check-square-o', isChosen)
  #-----------------------------------------------------------------------

  class List.Empty extends App.Views.ItemView
    template: 'references_tags/list/_empty'
    tagName: 'tr'

    ui:
      btnAdd: 'a[name=btnAdd]'

    events:
      'click @ui.btnAdd': 'add'

    add: (e) ->
      e.stopPropagation()
      model = App.request 'tag:new:entity'
      App.request 'tag:edit', model
      false

  #-----------------------------------------------------------------------

  class List.Tags extends App.Views.CompositeView
    template: 'references_tags/list/_tags'
    childView: List.Tag
    emptyView: List.Empty
    childViewContainer: 'tbody'
    className: 'container-fluid'

    ui:
      tickbox: 'th:first-child'

    events:
      'click @ui.tickbox': (e) ->
        e.stopPropagation()
        if $('i', @ui.tickbox).toggleClass('fa-square-o').toggleClass('fa-check-square-o').hasClass('fa-square-o')
          @collection.chooseNone()
        else
          @collection.chooseAll()

    collectionEvents:
      'sync': 'render'

    onBeforeShow: ->
      @$el.css
        'padding-top': '90px'
