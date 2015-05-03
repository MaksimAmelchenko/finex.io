@CashFlow.module 'CashFlowsIEsListApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.IEDetail extends App.Views.ItemView
    template: 'cashflows_ies_list/edit/_detail'
    tagName: 'tr'

    ui:
      tickbox: 'td:first-child'

    events:
      'click @ui.tickbox, .date': (e) ->
        e.stopPropagation()
        @model.toggleChoose()

      'click': ->
        if not getSelection().toString()
          @model.collection.chooseNone()
          @model.choose @model
          App.request 'ie:detail:edit', @model, @model.collection,
            isSync: false

    modelEvents:
      'change': 'render'

    onRender: ->
      isChosen = @model.isChosen()

      $('i', @ui.tickbox)
      .toggleClass('fa-square-o', !isChosen)
      .toggleClass('fa-check-square-o', isChosen)

      @$el
      .toggleClass('info', isChosen)
      .toggleClass('warning', @model.get('isNotConfirmed'))
      .toggleClass('danger', @model.isExpired())

  #----------

  class Edit.EmptyIEDetails extends App.Views.ItemView
    template: 'cashflows_ies_list/edit/_details_empty'
    tagName: 'tr'

  #----------

  class Edit.IEDetails extends App.Views.CompositeView
    template: 'cashflows_ies_list/edit/_details'

    emptyView: Edit.EmptyIEDetails
    childView: Edit.IEDetail
    childViewContainer: 'tbody'

    ui:
      btnAdd: '.btn[name=btnAdd]'
      btnDel: '.btn[name=btnDel]'
      tickbox: 'th:first-child'
      selectedTotal: 'tr[name=selectedTotal]'
      total: 'tr[name=total]'

    events:
      'click @ui.btnAdd': 'add'
      'click @ui.btnDel': 'del'
      'click @ui.tickbox': (e) ->
        e.stopPropagation()

        i = $('i', @ui.tickbox).toggleClass('fa-square-o').toggleClass('fa-check-square-o')
        if i.hasClass('fa-square-o')
          @collection.chooseNone()
        else
          @collection.chooseAll()

    initialize: ->
      @listenTo @collection, 'collection:chose:none', =>
        @ui.btnDel.amkDisable()

      @listenTo @collection, 'collection:chose:some collection:chose:all', =>
        @ui.btnDel.amkEnable()

    add: =>
      ieDetail = App.request 'ie:detail:new:entity'
      App.request 'ie:detail:edit', ieDetail, @collection,
        isSync: false

    del: ->
      @collection.remove @collection.getChosen()

    onRender: ->
      @ui.btnDel.amkDisable() if @collection.getChosen().length is 0

      @total = new Edit.IEDetailTotal
        collection: @collection

      @listenTo @total, 'render', (view) =>
        @ui.total.html view.$el.html()

      @total.render()


      @selectedTotal = new Edit.IEDetailSelectedTotal
        collection: @collection

      @listenTo @selectedTotal, 'render', (view) =>
        @ui.selectedTotal.html view.$el.html()

      @selectedTotal.render()

    onDestroy: ->
      @total.destroy()
      @selectedTotal.destroy()


  #----------

  class Edit.IE extends App.Views.Layout
    template: 'cashflows_ies_list/edit/layout'
    className: 'container-fluid'
    childView: Edit.IEDetail

    regions:
      detailsRegion: '[name=details-region]'

    ui:
      contractor: '[name=contractor]'
      note: '[name=note]'
      tags: '[name=tags]'
      table: 'tbody'


    events:
      'click .btn[name=btnSave]': 'save'
      'click .btn[name=btnCancel]': 'cancel'
#      'click [name=btnBack]': 'cancel'

#    modelEvents:
#      'change': 'render'

    initialize: (options = {}) ->
      @config = options.config

    serialize: ->
      idContractor: @ui.contractor.select2('data')?.id || null
      note: @ui.note.val()
      tags: @ui.tags.select2 'val'
      ieDetails: (@model.get('_ieDetails').toJSON()).reverse()

    getPatch: ->
      result = compareJSON @model.toJSON(), @serialize(), 'ieDetails'

      # Details
      _ieDetails = @model.get('_ieDetails').toJSON()
      ieDetails = @model.get('ieDetails')

      removed = []
      # @formatter:off
      removed = _.map _.difference(_.pluck(ieDetails, 'idIEDetail'), _.pluck(_ieDetails, 'idIEDetail')), (idIEDetail) ->
        idIEDetail: idIEDetail
        _destroy: true
      # @formatter:on

      added = []
      added = _.filter(_ieDetails, (item) ->
        !item.idIEDetail)

      changed = []
      filter = ['idAccount', 'idMoney', 'idCategory', 'idUnit', 'sign', 'dIEDetail', 'reportPeriod',
                'quantity', 'sum', 'isNotConfirmed', 'note', 'tags']

      # @formatter:off
      _.each _.intersection(_.pluck(ieDetails, 'idIEDetail'), _.pluck(_ieDetails, 'idIEDetail')), (idIEDetail) ->
        diff = compareJSON(_.findWhere(ieDetails, {idIEDetail: idIEDetail}), _.pick(_.findWhere(_ieDetails, {idIEDetail: idIEDetail}), filter))
        if !_.isEmpty(diff) then changed.push _.extend({idIEDetail: idIEDetail}, diff)
      # @formatter:on

      details = [].concat removed, added, changed
      result['ieDetails'] = details.reverse() if !_.isEmpty(details)

      result

    save: ->
      if @model.isNew()
        @model.save @serialize(),
          success: (model, resp, options) =>
            # Add new tags to collection
            App.entities.tags.add (resp.newTags) if resp.newTags
            @trigger 'form:after:save', model
      else
        patch = @getPatch()

        if !_.isEmpty patch
          @model.save patch,
            patch: true
            success: (model, resp, options) =>
              # Add new tags to collection
              App.entities.tags.add (resp.newTags) if resp.newTags
              @trigger 'form:after:save', model
        else
          @trigger 'form:after:save', @model

    cancel: ->
      @trigger 'form:cancel'

    onRender: ->
      @ui.contractor.select2
        allowClear: true
        placeholder: 'Нет'
        data: CashFlow.entities.contractors.map (contractor)->
          id: contractor.id
          text: contractor.get('name')
      @ui.contractor.select2('val', @model.get('idContractor'))

      @ui.note.val @model.get('note')

      @ui.tags.select2
        tokenSeparators: [',']
        tags: CashFlow.entities.tags.map (tag) ->
          tag.get('name')
      @ui.tags.select2('val', @model.get('tags'))

      # IEDetail
      editIEDetailsView = new Edit.IEDetails
        collection: @model.get('_ieDetails')

      @detailsRegion.show editIEDetailsView


    onDestroy: ->
      @ui.contractor.select2 'destroy'
      @ui.tags.select2 'destroy'


  #----------

  class Edit.IEDetailTotal extends App.Views.ItemView
    template: 'cashflows_ies_list/edit/_detail_total'
    tagName: 'tr'

    collectionEvents:
      'add remove change:sign change:sum change:idMoney': 'render'

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

  #----------

  class Edit.IEDetailSelectedTotal extends App.Views.ItemView
    template: 'cashflows_ies_list/edit/_detail_selected_total'
    tagName: 'tr'

    collectionEvents:
      'add remove change:sign change:sum change:idMoney collection:chose:some collection:chose:all collection:chose:none': 'render'

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

