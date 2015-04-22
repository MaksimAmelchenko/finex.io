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
      @$el.toggleClass('info', isChosen)
      $('i', @ui.tickbox).toggleClass('fa-square-o', !isChosen).toggleClass('fa-check-square-o', isChosen)

      @$el.toggleClass 'warning', @model.get('isNotConfirmed')
      @$el.toggleClass 'danger', @model.isExpired()


  #-----------------------------------------------------------------------

  class Edit.EmptyIEDetails extends App.Views.ItemView
    template: 'cashflows_ies_list/edit/_details_empty'
    tagName: 'tr'

  #-----------------------------------------------------------------------
  class Edit.IEDetails extends App.Views.CompositeView
    template: 'cashflows_ies_list/edit/_details'

    emptyView: Edit.EmptyIEDetails
    childView: Edit.IEDetail
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
      @ui.btnDel.amkDisable() if @collection.getChosen().length is 0

    add: =>
      ieDetail = App.request 'ie:detail:new:entity'
      App.request 'ie:detail:edit', ieDetail, @collection,
        isSync: false

    del: ->
      @collection.remove @collection.getChosen()

  #-----------------------------------------------------------------------

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
      removed = _.map _.difference(_.pluck(ieDetails, 'idIEDetail'), _.pluck(_ieDetails, 'idIEDetail')), (idIEDetail) ->
        idIEDetail: idIEDetail
        _destroy: true

      added = []
      added = _.filter(_ieDetails, (item) ->
        !item.idIEDetail)

      changed = []
      filter = ['idAccount', 'idMoney', 'idCategory', 'idUnit', 'sign', 'dIEDetail', 'reportPeriod', 'quantity', 'sum', 'isNotConfirmed', 'note', 'tags']

      _.each _.intersection(_.pluck(ieDetails, 'idIEDetail'), _.pluck(_ieDetails, 'idIEDetail')), (idIEDetail) ->
        diff = compareJSON(_.findWhere(ieDetails, {idIEDetail: idIEDetail}), _.pick(_.findWhere(_ieDetails, {idIEDetail: idIEDetail}), filter))
        if !_.isEmpty(diff) then changed.push _.extend({idIEDetail: idIEDetail}, diff)

      details = [].concat removed, added, changed
      result['ieDetails'] = details.reverse() if !_.isEmpty(details)

      result

    save: ->
#      debugger
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
