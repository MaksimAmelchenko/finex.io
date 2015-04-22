@CashFlow.module 'ReferencesUnitsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'references_units/list/layout'

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
    template: 'references_units/list/_panel'
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
      model = App.request 'unit:new:entity'
      App.request 'unit:edit', model

    del: ->
      model.destroy()  for model in  @collection.getChosen()

    refresh: ->
      App.request 'unit:entities',
        force: true

    onRender: ->
      if @collection.getChosen().length is 0 or @collection.getFirstChosen().get('idUser') is null
        @ui.btnDel.amkDisable()

  #-----------------------------------------------------------------------

  class List.Unit extends App.Views.ItemView
    template: 'references_units/list/_unit'
    tagName: 'tr'

#    triggers:
#      'click': 'unit:clicked'

    modelEvents:
      'change': 'render'
    ui:
      tickbox: 'td:first-child'

    events:
#      'click @ui.tickbox': (e) ->
#        e.stopPropagation()
#        @model.toggleChoose() if @model.get('idUser') isnt null

      'click': (e) ->
        e.stopPropagation()
        @model.toggleChoose() unless getSelection().toString() or @model.get('idUser') is null
      'click a': ->
        if @model.get('idUser')
          App.request 'unit:edit', @model
        false

    initialize: ->
      if @model.get('idUser') is null
        @$el.addClass 'system'

    onRender: ->
      if @model.get('idUser') isnt null
        isChosen = @model.isChosen()
        @$el.toggleClass('info', isChosen)
        $('i', @ui.tickbox).toggleClass('fa-square-o', !isChosen).toggleClass('fa-check-square-o', isChosen)
      else
        $('i', @ui.tickbox).addClass('fa-square-o').addClass('disabled')

  #-----------------------------------------------------------------------

  class List.Empty extends App.Views.ItemView
    template: 'references_units/list/_empty'
    tagName: 'tr'

  #-----------------------------------------------------------------------

  class List.Units extends App.Views.CompositeView
    template: 'references_units/list/_units'
    childView: List.Unit
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
#          @collection.chooseAll()
          model.choose() for model in @collection.models when model.get('idUser') isnt null


    collectionEvents:
      'sync': 'render'

    onBeforeShow: ->
      @$el.css
        'padding-top': '90px'
