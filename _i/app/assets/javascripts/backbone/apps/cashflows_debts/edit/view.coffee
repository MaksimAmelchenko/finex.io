@CashFlow.module 'CashFlowsDebtsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.DebtDetail extends App.Views.ItemView
    template: 'cashflows_debts/edit/_detail'
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
          App.request 'debt:detail:edit', @model


    modelEvents:
      'change': 'render'

    onRender: ->
      isChosen = @model.isChosen()
      @$el.toggleClass('info', isChosen)
      $('i', @ui.tickbox).toggleClass('fa-square-o', !isChosen).toggleClass('fa-check-square-o', isChosen)


  #-----------------------------------------------------------------------

  class Edit.EmptyDebtDetails extends App.Views.ItemView
    template: 'cashflows_debts/edit/_details_empty'
    tagName: 'tr'

  class Edit.DebtDetails extends App.Views.CompositeView
    template: 'cashflows_debts/edit/_details'

    emptyView: Edit.EmptyDebtDetails
    childView: Edit.DebtDetail
    childViewContainer: 'tbody'

    ui:
      btnAdd: '.btn[name=btnAdd]'
      btnDel: '.btn[name=btnDel]'
      tickbox: 'th:first-child'

    events:
      'click @ui.btnAdd': 'add'
      'click @ui.btnDel': 'del'
      'click @ui.tickbox': (e) ->
        e.stopPropagation()
        if $('i', @ui.tickbox).toggleClass('fa-square-o').toggleClass('fa-check-square-o').hasClass('fa-square-o')
          @collection.chooseNone()
        else
          @collection.chooseAll()

    initialize: ->
      @listenTo @collection, 'collection:chose:none', =>
        @ui.btnDel.amkDisable()

      @listenTo @collection, 'collection:chose:some collection:chose:all', =>
        @ui.btnDel.amkEnable()

    onRender: ->
      @ui.btnDel.amkDisable()

    add: =>
      detail = App.request 'debt:detail:new:entity'
      App.request 'debt:detail:edit', detail, @collection

    del: ->
      @collection.remove @collection.getChosen()

  #-----------------------------------------------------------------------

  class Edit.Debt extends App.Views.Layout
    template: 'cashflows_debts/edit/layout'
    className: 'container-fluid'
    childView: Edit.DebtDetail

    regions:
      detailsRegion: '[name=details-region]'

    ui:
      form: 'form'
      contractor: '[name=contractor]'
      note: '[name=note]'
      tags: '[name=tags]'
      table: 'tbody'

    events:
      'click .btn[name=btnSave]': 'save'
      'click .btn[name=btnCancel]': 'cancel'

#    modelEvents:
#      'change': 'render'

    initialize: (options = {}) ->
      @config = options.config

    serialize: ->
      idContractor: numToJSON (@ui.contractor.select2('data')?.id || null)
      note: @ui.note.val()
      tags: @ui.tags.select2 'val'
      debtDetails: (@model.get('_debtDetails').toJSON()).reverse()

    getPatch: ->
      result = compareJSON @model.toJSON(), @serialize(), 'debtDetails'

      # Details
      _debtDetails = @model.get('_debtDetails').toJSON()
      debtDetails = @model.get('debtDetails')

      removed = []
      removed = _.map _.difference(_.pluck(debtDetails, 'idDebtDetail'), _.pluck(_debtDetails, 'idDebtDetail')), (idDebtDetail) ->
        idDebtDetail: idDebtDetail
        _destroy: true

      added = []
      added = _.filter(_debtDetails, (item) ->
        !item.idDebtDetail)

      changed = []
      filter = ['idAccount', 'idMoney', 'idCategory', 'sign', 'dDebtDetail', 'reportPeriod', 'sum', 'note', 'tags']

      _.each _.intersection(_.pluck(debtDetails, 'idDebtDetail'), _.pluck(_debtDetails, 'idDebtDetail')), (idDebtDetail) ->
        diff = compareJSON(_.findWhere(debtDetails, {idDebtDetail: idDebtDetail}), _.pick(_.findWhere(_debtDetails, {idDebtDetail: idDebtDetail}), filter))
        if !_.isEmpty(diff) then changed.push _.extend({idDebtDetail: idDebtDetail}, diff)

      details = [].concat removed, added, changed
      result['debtDetails'] = details.reverse() if !_.isEmpty(details)

      result

    save: ->
      return if not @ui.form.valid()

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
      @ui.contractor.select2()
      # for jQuery Validation Plugin
      @ui.contractor.on 'change', ->
        $(@).trigger 'blur'

#        allowClear: true
#        data: CashFlow.entities.contractors.map (contractor)->
#          id: contractor.id
#          text: contractor.get('name')

      @ui.contractor.select2('val', @model.get('idContractor'))

      @ui.note.val @model.get('note')

      @ui.tags.select2
        tokenSeparators: [',']
        tags: CashFlow.entities.tags.map (tag) ->
          tag.get('name')
      @ui.tags.select2('val', @model.get('tags'))

      # DebtDetail
      editDebtDetailsView = new Edit.DebtDetails
        collection: @model.get('_debtDetails')

      @detailsRegion.show editDebtDetailsView

      @ui.form.validate
        rules:
          contractor:
            required: true
        messages:
          contractor:
            required: 'Пожалуйста, выберите контрагента',


    onDestroy: ->
      @ui.contractor.select2 'destroy'
      @ui.tags.select2 'destroy'
