@CashFlow.module 'UsersApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'users/list/layout'

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
    template: 'users/list/_panel'
    className: 'container-fluid'

    ui:
      btnInvite: '.btn[name=btnInvite]'
      btnRefresh: '.btn[name=btnRefresh]'

    events:
      'click @ui.btnInvite': 'invite'
      'click @ui.btnRefresh': 'refresh'

    collectionEvents:
      'sync': 'render'

    invite: ->
      App.request 'user:invite'

    refresh: ->
      App.request 'user:entities',
        force: true

  #-----------------------------------------------------------------------

  class List.User extends App.Views.ItemView
    template: 'users/list/_user'
    tagName: 'tr'

  #-----------------------------------------------------------------------

  class List.Empty extends App.Views.ItemView
    template: 'users/list/_empty'
    tagName: 'tr'

    ui:
      btnInvite: 'a[name=btnInvite]'

    events:
      'click @ui.btnInvite': 'invite'

    add: (e) ->
      e.stopPropagation()
      #      model = App.request 'tag:new:entity'
      #      App.request 'tag:edit', model
      false

  #-----------------------------------------------------------------------

  class List.Users extends App.Views.CompositeView
    template: 'users/list/_users'
    childView: List.User
    emptyView: List.Empty
    childViewContainer: 'tbody'
    className: 'container-fluid'

    collectionEvents:
      'sync': 'render'

    onBeforeShow: ->
      @$el.css
        'padding-top': '90px'
