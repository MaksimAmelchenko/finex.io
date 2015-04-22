@CashFlow.module 'ReferencesAccountsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'references_accounts/list/layout'

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
    template: 'references_accounts/list/_panel'
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
      model = App.request 'account:new:entity'
      App.request 'account:edit', model

    del: ->
      (if model.get('permit') is 7 then model.destroy()) for model in  @collection.getChosen()

    refresh: ->
      App.request 'account:entities',
        force: true

    onRender: ->
      @ui.btnDel.amkDisable() if @collection.getChosen().length is 0

  #-----------------------------------------------------------------------

  class List.Account extends App.Views.ItemView
    template: 'references_accounts/list/_account'
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
        if @model.get('permit') is 7
          App.request 'account:edit', @model
        false

    onRender: ->
      isChosen = @model.isChosen()
      @$el.toggleClass('info', isChosen)
      $('i', @ui.tickbox).toggleClass('fa-square-o', !isChosen).toggleClass('fa-check-square-o', isChosen)

  #-----------------------------------------------------------------------

  class List.Empty extends App.Views.ItemView
    template: 'references_accounts/list/_empty'
    tagName: 'tr'

    ui:
      btnAdd: 'a[name=btnAdd]'

    events:
      'click @ui.btnAdd': 'add'

    add: (e) ->
      e.stopPropagation()
      model = App.request 'account:new:entity'
      App.request 'account:edit', model
      false


  #-----------------------------------------------------------------------

  class List.Accounts extends App.Views.CompositeView
    template: 'references_accounts/list/_accounts'
    childView: List.Account
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

    onBeforeShow: ->
      @$el.css
        'padding-top': '90px'
