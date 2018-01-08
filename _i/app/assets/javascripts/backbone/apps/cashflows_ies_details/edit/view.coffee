@CashFlow.module 'CashFlowsIEsDetailsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.IEDetail extends App.Views.Layout
    template: 'cashflows_ies_details/edit/layout'

    dialog: ->
      title: @getTitle()
      keyboard: false
      backdrop: 'static'

    form:
      focusFirstInput: false
      syncing: true

    ui:
      dIEDetail: '[name=dIEDetail]'
      reportPeriod: '[name=reportPeriod]'
      account: '[name=account]'
      category: '[name=category]'
      sum: '[name=sum]'
      money: 'span[name=money]'
      quantity: '[name=quantity]'
      unit: 'span[name=unit]'
      isNotConfirmed: '[name=isNotConfirmed]'
      note: '[name=note]'
      tags: '[name=tags]'
      form: 'form'
      btnSave: '.btn[name=btnSave]'
      btnMore: '.btn[name=btnMore]'
      btnAddCategory: '.btn[name=btnAddCategory]'

    events:
      'click @ui.btnMore': 'more'
      'click @ui.btnSave': 'save'
      'click @ui.btnAddCategory': 'addCategory'
      'click .btn[name=btnCancel]': 'cancel'
      'changeDate @ui.dIEDetail': 'changeDateDIEDetail'
      'keydown @ui.sum': 'keyPress'
      'focusout @ui.sum': 'recalculateSum'
      'click div[name=money] ul.dropdown-menu li': 'selectMoney'
      'click div[name=unit] ul.dropdown-menu li': 'selectUnit'

    initialize: (options = {}) ->
      options.config or= {}

      _.defaults options.config,
        focusField: 'account'

      @config = options.config

    updateMoneyPrecision: (idMoney) ->
      money = App.entities.moneys.findWhere({idMoney})
      @precision = money.get('precision')

    recalculateSum: ->
      value = _.trim @ui.sum.val()
      if value isnt ''
        value = value.replace(/[,ю]/g, '.').replace(/\s/g, '')
        try
          sum = eval(value)
        catch
          undefined

        @ui.sum.val(round(sum, @precision)) if _.isNumber(sum)

    keyPress: (e) ->
      code = e.keyCode || e.which
      if code is 13
        @recalculateSum()

    selectMoney: (e)->
      e.preventDefault()
      li = $(e.currentTarget)
      li.siblings().removeClass('active').end().addClass('active')
      @ui.money.text(li.data('text')).data('idMoney', li.data('idMoney'))
      @updateMoneyPrecision(li.data('idMoney'))

    selectUnit: (e)->
      e.preventDefault()
      li = $(e.currentTarget)
      li.siblings().removeClass('active').end().addClass('active')

      @ui.unit.text(li.data('text')).data('idUnit', li.data('idUnit'))

    changeDateDIEDetail: ->
      # reportPeriod is dependence from dIEDetail unless it does not changed
      if @ui.reportPeriod.data('isLinked') and moment(@ui.reportPeriod.datepicker('getDate')).isValid()
        oldDate = @ui.dIEDetail.data('oldDate') || @ui.dIEDetail.datepicker('getDate')

        if moment(oldDate).format('YYYYMM') is moment(@ui.reportPeriod.datepicker('getDate')).format('YYYYMM')
          if moment(oldDate).format('YYYYMM') isnt moment(@ui.dIEDetail.datepicker('getDate')).format('YYYYMM')
            @ui.reportPeriod.datepicker('setDate',
              moment(@ui.dIEDetail.datepicker('getDate')).startOf('month').toDate())
        else
          @ui.reportPeriod.data 'isLinked', false

      @ui.dIEDetail.data('oldDate', @ui.dIEDetail.datepicker('getDate'))


    getTitle: ->
      if @model.get('idPlan')
        "Добавление запланированной операции"
      else
        "#{if @model.isNew() then 'Добавление' else 'Редактирование'} операции"

    onRender: ->
      @updateMoneyPrecision(@model.get('idMoney'))

      @ui.dIEDetail.datepicker('setDate', moment(@model.get('dIEDetail'), 'YYYY-MM-DD').toDate())
      @ui.reportPeriod.datepicker('setDate',
        moment(@model.get('reportPeriod'), 'YYYY-MM-DD').toDate())

      @ui.account.select2
        placeholder: 'Выберите счет'
      #        nextSearchTerm: (selectedObject, currentSearchTerm) ->
      #          currentSearchTerm
      @ui.account.select2('val', @model.get('idAccount'))
      # for jQuery Validation Plugin
      @ui.account.on 'change', ->
        $(@).trigger 'blur'

      @ui.category.select2
        minimumInputLength: if @ui.category.children().size() > 300 then 2 else 0
        placeholder: 'Выберите категорию'
        matcher: (term, text, opt) ->
          App.Entities.categoryMatcher term, text, opt

      @ui.category
      .on 'select2-open', ->
        # step back in category hierarchy
        el = $(@).data('select2')
        if el.data() and el.search.val() is ''
          el.search.val s.strLeft(el.data().text, '&rarr;').trim()
          el.updateResults false
      .on 'change', ->
        # for jQuery Validation Plugin
        $(@).trigger 'blur'

      @ui.category.select2('val', @model.get('idCategory'))

      @ui.quantity.val @model.get('quantity')

      @ui.sum.val @model.get('sum')

      @ui.isNotConfirmed.prop('checked', @model.get('isNotConfirmed'))

      @ui.note.val @model.get('note')

      @ui.tags.select2
        tokenSeparators: [',']
        tags: CashFlow.entities.tags.map (tag) ->
          tag.get('name')
      @ui.tags.select2('val', @model.get('tags'))

      @$('[data-toggle=popover]').popover
        container: 'body'
        html: true
        trigger: 'hover click'

      @ui.form.validate
        onfocusout: false
        rules:
          category:
            required: true
          account:
            required: true
          dIEDetail_:
            required: true
          reportPeriod_:
            required: true
          sum:
            required: true
            number: true
            moreThan: 0
          quantity:
            number: true
            moreThan: 0
        messages:
          account:
            required: 'Пожалуйста, выберите счет'
          category:
            required: 'Пожалуйста, выберите категорию'
          dIEDetail_:
            required: 'Пожалуйста, укажите дату',
          reportPeriod_:
            required: 'Пожалуйста, укажите отчетный период',
          sum:
            required: 'Пожалуйста, укажите сумму'
            number: 'Пожалуйста, введите в поле "Сумма" число'
            moreThan: 'Сумма должна быть больше 0'
          quantity:
            number: 'Пожалуйста, введите в поле "Количество" число'
            moreThan: 'Количество должно быть больше 0'

      @ui.form.submit (e) ->
        e.preventDefault()


    onShow: ->
      if (@model.get('permit') & 3) isnt 3 and not @model.isNew()
        @$('.form-control, [type=radio], [type=checkbox]').prop('disabled', true)

        @ui.account.select2 'enable', false
        @ui.category.select2 'enable', false
        @ui.tags.select2 'enable', false
        #        @ui.unit.select2 'enable', false
        #        @ui.money.select2 'enable', false
        @ui.btnAddCategory.prop 'disabled', true
        @ui.btnSave.prop 'disabled', true
        @ui.btnMore.prop 'disabled', true

      _.defer =>
        if @ui[@config.focusField].hasClass 'select2'
          @ui[@config.focusField].select2('focus')
        else
          @ui[@config.focusField].focus()

    serialize: ->
      sign: numToJSON @$('input[name=sign]:checked').val()
      dIEDetail: moment(@ui.dIEDetail.datepicker('getDate')).format('YYYY-MM-DD')
      reportPeriod: moment(@ui.reportPeriod.datepicker('getDate')).format('YYYY-MM-DD')
      idAccount: numToJSON @ui.account.select2('data').id
      idCategory: numToJSON @ui.category.select2('data').id
      quantity: numToJSON @ui.quantity.val()
      idUnit: numToJSON @ui.unit.data 'idUnit'
      sum: numToJSON @ui.sum.val()
      idMoney: numToJSON @ui.money.data 'idMoney'
      isNotConfirmed: @ui.isNotConfirmed.prop('checked')
      note: @ui.note.val()
      tags: @ui.tags.select2 'val'


    getPatch: ->
      compareJSON @model.toJSON(), @serialize()


    cancel: ->
      @trigger 'form:cancel'


    more: (e) ->
      e.preventDefault()
      @_save
        isMore: true


    save: (e) ->
      e.preventDefault()
      @_save()


    _save: (options) ->
      return if not @ui.form.valid()

      _options = options
      if @config.isSync
        if @model.isNew()
          @model.save @serialize(),
            success: (model, resp, options) =>
              # Add new tags to collection
              App.entities.tags.add (resp.newTags) if resp.newTags
              @trigger 'form:after:save', model, _options
        else
          patch = @getPatch()

          if !_.isEmpty patch
            @model.save patch,
              patch: true
              success: (model, resp, options) =>
                # Add new tags to collection
                App.entities.tags.add (resp.newTags) if resp.newTags
                @trigger 'form:after:save', model, _options
          else
            @trigger 'form:after:save', @model, _options
      else
        @model.set @serialize()
        @trigger 'form:after:save', @model, _options

    onDestroy: ->
      @ui.account.select2 'destroy'
      @ui.category.select2 'destroy'
      @ui.tags.select2 'destroy'

    addCategory: ->
      model = App.request 'category:new:entity'
      current = @ui.category.select2('data')?.id || null
      if current
        model.set('parent', App.entities.categories.get(current).get('parent'))
      editController = App.request 'category:edit', model
      editController.on 'form:after:save', (model) =>
        @ui.category.append ("<option value='#{model.id}'>#{model.path(true)}</option>")
        @ui.category.select2('val', model.id)



