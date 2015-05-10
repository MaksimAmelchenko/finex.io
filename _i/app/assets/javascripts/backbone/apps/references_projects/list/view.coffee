@CashFlow.module 'ReferencesProjectsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'references_projects/list/layout'

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
    template: 'references_projects/list/_panel'
    className: 'container-fluid'

    ui:
      btnAdd: '.btn[name=btnAdd]'
      btnDel: '.btn[name=btnDel]'
      btnRefresh: '.btn[name=btnRefresh]'
      btnCopy: '.btn[name=btnCopy]'
      btnMerge: '.btn[name=btnMerge]'

    initialize: ->
      @listenTo @collection, 'collection:unchose:one', =>
        @ui.btnDel.amkDisable()

      @listenTo @collection, 'collection:chose:one', =>
        # do not allow to remove active project
        if @collection.getFirstChosen().id isnt App.request 'active:project'
          @ui.btnDel.amkEnable()
        else
          @ui.btnDel.amkDisable()

      App.vent.on 'change:active:project', =>
        if @collection.getFirstChosen()
          @collection.trigger 'collection:chose:one'


    events:
      'click @ui.btnAdd': 'add'
      'click @ui.btnDel': 'del'
      'click @ui.btnRefresh': 'refresh'
      'click @ui.btnCopy': 'copy'
      'click @ui.btnMerge': 'merge'

    collectionEvents:
      'sync': 'render'

    add: ->
      model = App.request 'project:new:entity'
      App.request 'project:edit', model

    del: ->
      #(if model.get('permit') is 7 then model.destroy()) for model in @collection.getChosen()
      model = @collection.getFirstChosen()
      if model.get('permit') is 7 and confirm('Вы уверены, что хотите удалить данный проект?')

        @addOpacityWrapper()
        model.destroy
          success: =>
            @addOpacityWrapper(false)
          error: =>
            @addOpacityWrapper(false)

    refresh: ->
      App.request 'project:entities',
        force: true

    copy: ->
      current = @collection.getFirstChosen()
      App.request 'project:copy',
        idProjectFrom: current?.id || null

    merge: ->
      current = @collection.getFirstChosen()
      App.request 'project:merge',
        idTargetProject: current?.id || null

    onRender: ->
      @ui.btnDel.amkDisable() if @collection.getChosen().length is 0

  #-----------------------------------------------------------------------

  class List.Project extends App.Views.ItemView
    template: 'references_projects/list/_project'
    tagName: 'tr'

#    triggers:
#      'click': 'project:clicked'

    modelEvents:
      'change': 'render'

#    ui:
#      tickbox: 'td:first-child'

    events:
#      'click @ui.tickbox, [role=name]': (e) ->
#        e.stopPropagation()
#        @model.toggleChoose()
      'click': (e) ->
        e.stopPropagation()
        @model.toggleChoose() unless getSelection().toString()

      'click a': ->
        if @model.get('permit') is 7
          @model.choose()
          App.request 'project:edit', @model
        false

    onRender: ->
      isChosen = @model.isChosen()
      @$el.toggleClass('info', isChosen)
  #      $('i', @ui.tickbox).toggleClass('fa-square-o', !isChosen).toggleClass('fa-check-square-o', isChosen)


  #-----------------------------------------------------------------------

  class List.Empty extends App.Views.ItemView
    template: 'references_projects/list/_empty'
    tagName: 'tr'


  #-----------------------------------------------------------------------

  class List.Projects extends App.Views.CompositeView
    template: 'references_projects/list/_projects'
    childView: List.Project
    emptyView: List.Empty
    childViewContainer: 'tbody'
    className: 'container-fluid'

    collectionEvents:
      'sync': 'render'

    onBeforeShow: ->
      @$el.css
        'padding-top': '90px'
