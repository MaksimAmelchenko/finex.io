@CashFlow.module 'PlansCashFlowItemsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'plans_cashflow_items/list/layout'

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

  #--------------------------------------------------------------------------------

  class List.Pagination extends App.Views.ItemView
    template: 'plans_cashflow_items/list/_pagination'

    ui:
      btnPrevious: '.btn[name=btnPreviousPage]'
      btnNext: '.btn[name=btnNextPage]'

    events:
      'click @ui.btnPrevious': 'previousPage'
      'click @ui.btnNext': 'nextPage'

    collectionEvents:
      'add remove sync': 'render'

    templateHelpers: ->
      limit: @collection.limit
      offset: @collection.offset
      total: @collection.total

    previousPage: ->
      @collection.previousPage ->
        window.scrollTo(0, 0)

    nextPage: ->
      @collection.nextPage ->
        window.scrollTo(0, 0)

    onRender: ->
      @ui.btnPrevious.amkDisable() if @collection.isFirstPage()
      @ui.btnNext.amkDisable() if @collection.isLastPage()

  #--------------------------------------------------------------------------------

  class List.Panel extends App.Views.Layout
    template: 'plans_cashflow_items/list/_panel'
    className: 'container-fluid'

    regions:
      paginationRegion: '[name=pagination-region]'

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


    add: ->
      model = App.request 'plan:cashFlowItem:new:entity'
      App.request 'plan:cashFlowItem:edit', model, @collection

    del: ->
      model.destroy()  for model in  @collection.getChosen()

    refresh: ->
      @collection.resetPagination()

      App.request 'plan:cashFlowItem:entities',
        force: true

    onRender: ->
      if @collection.getChosen().length is 0
        @ui.btnDel.amkDisable()

      paginationView = new List.Pagination
        collection: @collection

      @paginationRegion.show paginationView
  #---------------------------------------------------------------------------------

  class List.PlanCashFlowItem extends App.Views.ItemView
    template: 'plans_cashflow_items/list/_plan_cashflow_item'
    tagName: 'tr'

    triggers:
      'click': 'planCashFlowItem:clicked'

    modelEvents:
      'change': 'render'

    events:
      'click td:first-child, .date': (e) ->
        e.stopPropagation()
        @model.toggleChoose()

    templateHelpers: ->
      _.extend super,
        schedule: @model.getSchedule()

    onRender: ->
      icon = @$('td:first-child > i')
      if @model.isChosen()
        @$el.addClass 'info'
        icon.addClass('fa-check-square-o')
      else
        @$el.removeClass 'info'
        icon.addClass('fa-square-o')

  #      @$el.toggleClass 'warning', @model.get('isNotConfirmed')
  #      @$el.toggleClass 'danger', @model.isExpired()

  #---------------------------------------------------------------------------------



  class List.Empty extends App.Views.ItemView
    template: 'plans_cashflow_items/list/_empty'
    tagName: 'tr'

  #--------------------------------------------------------------------------------

  class List.PlanCashFlowItems extends App.Views.CompositeView
    template: 'plans_cashflow_items/list/_plan_cashflow_items'
    childView: List.PlanCashFlowItem
    emptyView: List.Empty
    childViewContainer: 'tbody'
#    className: 'container-fluid'

    ui:
      tickbox: 'th:first-child'

    events:
      'click @ui.tickbox': (e) ->
        e.stopPropagation()
        if $('i',
          @ui.tickbox).toggleClass('fa-square-o').toggleClass('fa-check-square-o').hasClass('fa-square-o')
          @collection.chooseNone()
        else
          @collection.chooseAll()

    onBeforeShow: ->
      @$el.css
        'padding-top': '88px'
