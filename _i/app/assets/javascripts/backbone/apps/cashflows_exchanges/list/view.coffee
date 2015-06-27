@CashFlow.module 'CashFlowsExchangesApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'cashflows_exchanges/list/layout'

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
      App.execute('menu:set:badge', 'exchanges', @collection.totalPlanned,
        'Количество запланированных обменов')

    onDestroy: ->
      @addOpacityWrapper(false)

  # --------------------------------------------------------------------------------

  class List.Pagination extends App.Views.ItemView
    template: 'cashflows_exchanges/list/_pagination'

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

  # --------------------------------------------------------------------------------

  class List.Panel extends App.Views.Layout
    template: 'cashflows_exchanges/list/_panel'
    className: 'container-fluid'

    regions:
      paginationRegion: '[name=pagination-region]'

    ui:
      btnAdd: '.btn[name=btnAdd]'
      btnDel: '.btn[name=btnDel]'
      btnRefresh: '.btn[name=btnRefresh]'

      searchText: '[name=searchText]'
      isUseFilters: '[name=isUseFilters]'
      btnToggleFilters: '.btn[name=btnToggleFilters]'

      filters: '[name=filters]'

      dBegin: '[name=dBegin]'
      dEnd: '[name=dEnd]'
      accountsFrom: '[name=accountsFrom]'
      accountsTo: '[name=accountsTo]'
      tags: '[name=tags]'

    isShowFilters: false

    initialize: ->
      @listenTo @collection, 'collection:chose:none', =>
        @ui.btnDel.amkDisable()

      @listenTo @collection, 'collection:chose:some collection:chose:all', =>
        @ui.btnDel.amkEnable()

    events:
      'click @ui.btnAdd': 'add'
      'click @ui.btnDel': 'del'
      'click @ui.btnRefresh': 'refresh'
      'keypress @ui.searchText': 'keyPressSearchText'
      'change @ui.isUseFilters': 'changeIsUseFilters'
      'click @ui.btnToggleFilters': 'toggleFilters'

    #    collectionEvents:
    #      'sync': 'render'

    add: ->
      model = App.request 'exchange:new:entity'
      App.request 'exchange:edit', model, @collection

    del: ->
      for model in @collection.getChosen()
        if model.get('idPlan')
          do (model) ->
            App.xhrRequest
              type: 'POST'
              url: "plans/#{model.get('idPlan')}/cancel"
              data: JSON.stringify
                dExclude: model.get('dTransfer')
              success: (res, textStatus, jqXHR) ->
                model.collection.totalPlanned -= 1
                App.execute('menu:set:badge', 'exchanges', model.collection.totalPlanned,
                  'Количество запланированных обменов')
                model.destroy()

        else
          model.destroy()

    refresh: ->
      @collection.resetPagination()
      @focusedElement = @$(':focus')[0]?.name

      @collection.searchText = @ui.searchText.val()
      @collection.isUseFilters = @ui.isUseFilters.prop 'checked'
      @isShowFilters = @ui.filters.is(':visible')

      dBegin = moment @ui.dBegin.datepicker('getDate')
      @collection.filters.dBegin = if dBegin.isValid() then dBegin.format('YYYY-MM-DD') else null
      dEnd = moment @ui.dEnd.datepicker('getDate')
      @collection.filters.dEnd = if dEnd.isValid() then dEnd.format('YYYY-MM-DD') else null

      @collection.filters.accountsFrom = _.map @ui.accountsFrom.select2('val'), (item) ->
        parseInt item

      @collection.filters.accountsTo = _.map @ui.accountsTo.select2('val'), (item) ->
        parseInt item

      @collection.filters.tags = _.map @ui.tags.select2('val'), (item) ->
        parseInt item

      App.request 'exchange:entities',
        force: true

    keyPressSearchText: (e) ->
      if e.which is 13
        e.preventDefault()
        @refresh()

    toggleFilters: ->
      @ui.filters.slideToggle
        duration: 50
        complete: =>
          App.vent.trigger 'cashflows_exchanges:panel:resize', @$el.height()

      $('.fa-caret-down, .fa-caret-right', @ui.btnToggleFilters)
      .toggleClass('fa-caret-down')
      .toggleClass('fa-caret-right')

    changeIsUseFilters: ->
      @collection.isUseFilters = @ui.isUseFilters.prop('checked')
      @refresh()


    onRender: ->
      @ui.btnDel.amkDisable() if @collection.getChosen().length is 0

      @ui.searchText.val @collection.searchText
      @ui.isUseFilters.prop('checked', @collection.isUseFilters)

      @ui.dBegin.datepicker()
      if @collection.filters.dBegin
        @ui.dBegin.datepicker('setDate', moment(@collection.filters.dBegin, 'YYYY-MM-DD').toDate())

      @ui.dEnd.datepicker()
      if @collection.filters.dEnd
        @ui.dEnd.datepicker('setDate', moment(@collection.filters.dEnd, 'YYYY-MM-DD').toDate())

      @ui.accountsFrom.select2()
      @ui.accountsFrom.select2('val', @collection.filters.accountsFrom)

      @ui.accountsTo.select2()
      @ui.accountsTo.select2('val', @collection.filters.accountsTo)

      @ui.tags.select2()
      @ui.tags.select2('val', @collection.filters.tags)

      if @isShowFilters
        @ui.btnToggleFilters.trigger 'click'

      if @focusedElement is 'searchText'
        @ui.searchText.focus()

      paginationView = new List.Pagination
        collection: @collection

      @paginationRegion.show paginationView

      # Пусть будет стандартная подсказка
      #      @$('[data-toggle="tooltip"]').tooltip
      #        container: '#ribbon'
      #        delay:
      #          show: 1000

      App.vent.trigger 'cashflows_exchanges:panel:resize', @$el.height()

  # --------------------------------------------------------------------------------

  class List.Exchange extends App.Views.ItemView
    template: 'cashflows_exchanges/list/_exchange'
    tagName: 'tr'

    triggers:
      'click': 'exchange:clicked'

    ui:
      tickbox: 'td.tickbox'

    modelEvents:
      'change': 'render'
      'change:idPlan': ->
        @model.collection.totalPlanned -= 1
        App.execute('menu:set:badge', 'exchanges', @model.collection.totalPlanned,
          'Количество запланированных обменов')

    events:
      'click td.color-mark, td.tickbox, td.date': (e) ->
        e.stopPropagation()
        @model.toggleChoose()

    onRender: ->
      isChosen = @model.isChosen()
      @$el.toggleClass('info', isChosen)

      $('i', @ui.tickbox)
      .toggleClass('fa-square-o', !isChosen)
      .toggleClass('fa-check-square-o', isChosen)

      @$el.attr 'role', 'planned' if @model.get('idPlan')

  # --------------------------------------------------------------------------------

  class List.Empty extends App.Views.ItemView
    template: 'cashflows_exchanges/list/_empty'
    tagName: 'tr'


  # --------------------------------------------------------------------------------

  class List.Exchanges extends App.Views.CompositeView
    template: 'cashflows_exchanges/list/_exchanges'
    childView: List.Exchange
    emptyView: List.Empty
    childViewContainer: 'tbody'
    className: 'container-fluid'

    collectionEvents:
      'sync': 'render'

    ui:
      tickbox: 'th.tickbox'

    events:
      'click @ui.tickbox': (e) ->
        e.stopPropagation()

        i = $('i', @ui.tickbox)
        .toggleClass('fa-square-o')
        .toggleClass('fa-check-square-o')

        if i.hasClass('fa-square-o')
          @collection.chooseNone()
        else
          @collection.chooseAll()

    initialize: ->
      App.vent.on 'cashflows_exchanges:panel:resize', (height) =>
        @$el.css
          'padding-top': (height + 5) + 'px'

    onBeforeShow: ->
      @$el.css
        'padding-top': '88px'
