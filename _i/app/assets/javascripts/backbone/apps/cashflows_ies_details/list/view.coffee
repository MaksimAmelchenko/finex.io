@CashFlow.module 'CashFlowsIEsDetailsApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'cashflows_ies_details/list/layout'

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

  # --------------------------------------------------------------------------------

  class List.Pagination extends App.Views.ItemView
    template: 'cashflows_ies_details/list/_pagination'

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
    template: 'cashflows_ies_details/list/_panel'
    className: 'container-fluid'

    regions:
      paginationRegion: '[name=pagination-region]'

    ui:
      btnAdd: '.btn[name=btnAdd]'
      btnDel: '.btn[name=btnDel]'
      btnRefresh: '.btn[name=btnRefresh]'
      btnShowIE: '.btn[name=btnShowIE]'

      searchText: '[name=searchText]'
      isUseFilters: '[name=isUseFilters]'
      btnToggleFilters: '.btn[name=btnToggleFilters]'

      filters: '[name=filters]'

      dBegin: '[name=dBegin]'
      dEnd: '[name=dEnd]'
      sign: '[name=sign]'
      contractors: '[name=contractors]'
      accounts: '[name=accounts]'
      categories: '[name=categories]'
      tags: '[name=tags]'

    isShowFilters: false

    initialize: ->
      @listenTo @collection, 'collection:chose:none', =>
        @ui.btnDel.amkDisable()
        @ui.btnShowIE.amkDisable()


      @listenTo @collection, 'collection:chose:some collection:chose:all', =>
        @ui.btnDel.amkEnable()
        if @collection.getChosen().length is 1 and @collection.getChosen()[0].get('idIE')
          @ui.btnShowIE.amkEnable()
        else
          @ui.btnShowIE.amkDisable()

    events:
      'click @ui.btnAdd': 'add'
      'click @ui.btnDel': 'del'
      'click @ui.btnRefresh': 'refresh'
      'click @ui.btnShowIE': 'showIE'
      'keypress @ui.searchText': 'keyPressSearchText'
      'change @ui.isUseFilters': 'changeIsUseFilters'
      'click @ui.btnToggleFilters': 'toggleFilters'


    #    collectionEvents:
    #      'sync': 'render'

    add: ->
      model = App.request 'ie:detail:new:entity'
      App.request 'ie:detail:edit', model, @collection

    del: ->
      if @collection.getChosen().length > 1
        return if not confirm("Вы действительно хотите удалить несколько записей \n(#{@collection.getChosen().length} шт.) ?")

      for model in @collection.getChosen()
        if model.get('idPlan')
          do (model) ->
            App.xhrRequest
              type: 'POST'
              url: "plans/#{model.get('idPlan')}/cancel"
              data: JSON.stringify
                dExclude: model.get('dIEDetail')
              success: (res, textStatus, jqXHR) ->
                model.collection.totalPlanned -= 1
                App.execute('menu:set:badge', 'ies_details', model.collection.totalPlanned,
                  'Количество запланированных операций')
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
      @collection.filters.sign = if @ui.sign.select2('val') then +@ui.sign.select2('val') else null

      @collection.filters.contractors = _.map @ui.contractors.select2('val'), (item) ->
        parseInt item

      @collection.filters.accounts = _.map @ui.accounts.select2('val'), (item) ->
        parseInt item

      @collection.filters.categories = _.map @ui.categories.select2('val'), (item) ->
        parseInt item

      @collection.filters.tags = _.map @ui.tags.select2('val'), (item) ->
        parseInt item

      App.request 'ie:detail:entities',
        force: true

    showIE: ->
      model = App.request 'ie:entity', @collection.getFirstChosen().get('idIE')
      App.request 'ie:edit:ies_details', model, App.mainRegion


    keyPressSearchText: (e) ->
      if e.which is 13
        e.preventDefault()
        @refresh()

    toggleFilters: ->
      @ui.filters.slideToggle
        duration: 50
        complete: =>
          App.vent.trigger 'cashflows_ies_details:panel:resize', @$el.height()

      $('.fa-caret-down, .fa-caret-right',
        @ui.btnToggleFilters).toggleClass('fa-caret-down').toggleClass('fa-caret-right')

    changeIsUseFilters: ->
      @collection.isUseFilters = @ui.isUseFilters.prop('checked')
      @refresh()


    onRender: ->
      if @collection.getChosen().length is 0
        @ui.btnDel.amkDisable()
        @ui.btnShowIE.amkDisable()

      @ui.searchText.val @collection.searchText
      @ui.isUseFilters.prop('checked', @collection.isUseFilters)

      @ui.dBegin.datepicker()
      @ui.dBegin.datepicker('setDate',
        moment(@collection.filters.dBegin, 'YYYY-MM-DD').toDate()) if @collection.filters.dBegin
      @ui.dEnd.datepicker()
      @ui.dEnd.datepicker('setDate',
        moment(@collection.filters.dEnd, 'YYYY-MM-DD').toDate()) if @collection.filters.dEnd

      @ui.sign.select2()
      @ui.sign.select2('val', @collection.filters.sign)

      @ui.contractors.select2()
      @ui.contractors.select2('val', @collection.filters.contractors)

      @ui.accounts.select2()
      @ui.accounts.select2('val', @collection.filters.accounts)

      @ui.categories.select2
        minimumInputLength: if @ui.categories.children().size() > 300 then 2 else 0
      @ui.categories.select2('val', @collection.filters.categories)

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

      App.vent.trigger 'cashflows_ies_details:panel:resize', @$el.height()

  # --------------------------------------------------------------------------------

  class List.IEDetail extends App.Views.ItemView
    template: 'cashflows_ies_details/list/_ie_detail'
    tagName: 'tr'

    modelEvents:
      'change': 'render'
      'change:idPlan': ->
        @model.collection.totalPlanned -= 1
        App.execute('menu:set:badge', 'ies_details', @model.collection.totalPlanned,
          'Количество запланированных операций')

    ui:
      tickbox: 'td.tickbox'

    events:
      'click td.color-mark, td.tickbox, td.date': (e) ->
        e.stopPropagation()
        @model.toggleChoose()
      'click': ->
        if not getSelection().toString()
          @model.collection.chooseNone()
          @model.choose()
          App.request 'ie:detail:edit', @model, @model.collection

    onRender: ->
      isChosen = @model.isChosen()
      @$el.toggleClass('info', isChosen)

      $('i', @ui.tickbox)
      .toggleClass('fa-square-o', !isChosen)
      .toggleClass('fa-check-square-o', isChosen)

      @$el.toggleClass 'warning', @model.get('isNotConfirmed')
      @$el.toggleClass 'danger', @model.isExpired()

      @$el.attr 'role', 'planned' if @model.get('idPlan')

  # --------------------------------------------------------------------------------

  class List.IEDetailTotal extends App.Views.ItemView
    template: 'cashflows_ies_details/list/_ie_detail_total'
    tagName: 'tr'

    collectionEvents:
      'add remove sync': 'render'

    templateHelpers: ->
      _.extend super,
        moneys: =>
          App.Entities.sortListByMoney(_.uniq(@collection.pluck('idMoney')))

        balance: =>
          balance = {}

          _.each @collection.models, (model) ->
            idMoney = model.get('idMoney')
            balance[idMoney] or= {total: 0}

            if model.get('sign') is 1
              balance[idMoney]['income'] or= 0
              balance[idMoney]['income'] += model.get('sum')

            if model.get('sign') is -1
              balance[idMoney]['expense'] or= 0
              balance[idMoney]['expense'] += model.get('sum')

            balance[idMoney]['total'] += model.get('sign') * model.get('sum')
          balance

  # --------------------------------------------------------------------------------

  class List.IEDetailSelectedTotal extends App.Views.ItemView
    template: 'cashflows_ies_details/list/_ie_detail_selected_total'
    tagName: 'tr'

    collectionEvents:
      'add remove sync collection:chose:some collection:chose:all collection:chose:none': 'render'

    templateHelpers: ->
      _.extend super,
        moneys: =>
          items = []
          _.each @collection.models, (model) ->
            if model.isChosen() then items.push(model.get('idMoney'))

          App.Entities.sortListByMoney(_.uniq(items))

        balance: =>
          balance = {}

          _.each @collection.models, (model) ->
            if model.isChosen()
              idMoney = model.get('idMoney')
              balance[idMoney] or= {total: 0}

              if model.get('sign') is 1
                balance[idMoney]['income'] or= 0
                balance[idMoney]['income'] += model.get('sum')

              if model.get('sign') is -1
                balance[idMoney]['expense'] or= 0
                balance[idMoney]['expense'] += model.get('sum')

              balance[idMoney]['total'] += model.get('sign') * model.get('sum')
          balance

  # --------------------------------------------------------------------------------

  class List.Empty extends App.Views.ItemView
    template: 'cashflows_ies_details/list/_empty'
    tagName: 'tr'

  # --------------------------------------------------------------------------------

  class List.IEDetails extends App.Views.CompositeView
    template: 'cashflows_ies_details/list/_ie_details'
    childView: List.IEDetail
    emptyView: List.Empty
    childViewContainer: 'tbody'
    className: 'container-fluid'

    ui:
      tickbox: 'th.tickbox'
      selectedTotal: 'tr[name=selectedTotal]'
      total: 'tr[name=total]'

    collectionEvents:
      'sync:stop': ->
        App.execute('menu:set:badge', 'ies_details', @collection.totalPlanned,
          'Количество запланированных операций')

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
      App.vent.on 'cashflows_ies_details:panel:resize', (height) =>
        @$el.css
          'padding-top': (height + 5) + 'px'

    onBeforeShow: ->
      @$el.css
        'padding-top': '88px'

    onRender: ->
      @total = new List.IEDetailTotal
        collection: @collection

      @listenTo @total, 'render', (view) =>
        @ui.total.html view.$el.html()

      @total.render()

      @selectedTotal = new List.IEDetailSelectedTotal
        collection: @collection

      @listenTo @selectedTotal, 'render', (view) =>
        @ui.selectedTotal.html view.$el.html()

      @selectedTotal.render()

    onDestroy: ->
      @total.destroy()
      @selectedTotal.destroy()
