@CashFlow.module 'ReferencesMoneysApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'references_moneys/list/layout'

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
    template: 'references_moneys/list/_panel'
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
      model = App.request 'money:new:entity'
      App.request 'money:edit', model

    del: ->
      model.destroy() for model in  @collection.getChosen()

    refresh: ->
      App.request 'money:entities',
        force: true

    onRender: ->
      @ui.btnDel.amkDisable() if @collection.getChosen().length is 0

  #-----------------------------------------------------------------------

  class List.Money extends App.Views.ItemView
    template: 'references_moneys/list/_money'
    tagName: 'tr'

    modelEvents:
      'change': 'render'

    ui:
      tickbox: 'td:first-child'

    events:
      'click': (e) ->
        e.stopPropagation()
        @model.toggleChoose() unless getSelection().toString()
      'click a': ->
        #        @model.choose()
        App.request 'money:edit', @model
        false

    onRender: ->
      isChosen = @model.isChosen()
      @$el.toggleClass('info', isChosen)
      $('i', @ui.tickbox).toggleClass('fa-square-o', !isChosen).toggleClass('fa-check-square-o',
        isChosen)
      @$el.data('id-money', @model.id)


  #-----------------------------------------------------------------------

  class List.Empty extends App.Views.ItemView
    template: 'references_moneys/list/_empty'
    tagName: 'tr'

    ui:
      btnAdd: 'a[name=btnAdd]'

    events:
      'click @ui.btnAdd': 'add'

    add: (e) ->
      e.stopPropagation()
      model = App.request 'money:new:entity'
      App.request 'money:edit', model
      false


  #-----------------------------------------------------------------------

  class List.Moneys extends App.Views.CompositeView
    template: 'references_moneys/list/_moneys'
    childView: List.Money
    emptyView: List.Empty
    childViewContainer: 'tbody'
    className: 'container-fluid'

    ui:
      tickbox: 'th:first-child'

    events:
      'click @ui.tickbox': (e) ->
        e.stopPropagation()
        i = $('i', @ui.tickbox)
        if i.toggleClass('fa-square-o').toggleClass('fa-check-square-o').hasClass('fa-square-o')
          @collection.chooseNone()
        else
          @collection.chooseAll()

    onRender: ->
      @$('tbody')
      .sortable {
        handle: 'a'
        helper: (e, ui) ->
          ui.children().each ->
            $(this).width($(this).width())
          ui
        axis: 'y'
        cursor: 'move'
        update: =>
          data = $.map @$('tbody > tr'), (row) ->
            $(row).data('id-money')

          App.xhrRequest
            type: 'PUT'
            url: 'moneys/sort'
            data: JSON.stringify
              moneys: data
            success: (res, textStatus, jqXHR) ->
              App.request 'money:entities',
                force: true
      }
      .disableSelection()

    onBeforeShow: ->
      @$el.css
        'padding-top': '90px'
