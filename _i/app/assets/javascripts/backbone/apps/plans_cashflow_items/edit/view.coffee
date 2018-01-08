@CashFlow.module 'PlansCashFlowItemsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.PlanCashFlowItem extends App.Views.Layout
    template: 'plans_cashflow_items/edit/layout'

    dialog: ->
      title: @getTitle()
      keyboard: false
      backdrop: 'static'

    form:
      focusFirstInput: false
      syncing: true

    ui:
      form: 'form'
      dBegin: '[name=dBegin]'
      reportPeriod: '[name=reportPeriod]'
      account: '[name=account]'
      category: '[name=category]'
      sum: '[name=sum]'
      money: 'span[name=money]'
      quantity: '[name=quantity]'
      unit: 'span[name=unit]'
      note: '[name=note]'

      repeatType: '[name=repeatType]'
      _repeatOptions: 'div[name=_repeatOptions]'
    #      everyText: 'span[name=everyText]'
    #      repeatRate: '[name=repeatRate]'
    #      periodName: 'span[name=periodName]'
      _weekDays: 'div[name=_weekDays]'
      weekDays: '[name=weekDays]'
      _monthDays: 'div[name=_monthDays]'
      monthDays: 'select[name=monthDays]'

      _end: 'div[name=_end]'
      endType: 'select[name=endType]'
      _repeatCount: 'div[name=_repeatCount]'
      repeatCount: 'input[name=repeatCount]'
      _dEnd: 'div[name=_dEnd]'
      dEnd: '[name=dEnd]'

      contractor: '[name=contractor]'
      operationNote: '[name=operationNote]'
      operationTags: '[name=operationTags]'
      colorMark: '[name=colorMark]'

      btnSave: '.btn[name=btnSave]'

    events:
      'click @ui.btnSave': 'save'
      'click .btn[name=btnCancel]': 'cancel'
      'changeDate @ui.dBegin': 'changeDateDBegin'
      'keydown @ui.sum': 'keyPress'
      'focusout @ui.sum': 'recalculateSum'
      'click div[name=money] ul.dropdown-menu li': 'selectMoney'
      'click div[name=unit] ul.dropdown-menu li': 'selectUnit'
      'change @ui.repeatType': 'changeRepeatType'
      'change @ui.endType': 'changeEndType'


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

    changeDateDBegin: ->
      # reportPeriod is dependence from dBegin unless it does not changed
      if @ui.reportPeriod.data('isLinked') and moment(@ui.reportPeriod.datepicker('getDate')).isValid()
        oldDate = @ui.dBegin.data('oldDate') || @ui.dBegin.datepicker('getDate')

        if moment(oldDate).format('YYYYMM') is moment(@ui.reportPeriod.datepicker('getDate')).format('YYYYMM')
          if moment(oldDate).format('YYYYMM') isnt moment(@ui.dBegin.datepicker('getDate')).format('YYYYMM')
            @ui.reportPeriod.datepicker('setDate',
              moment(@ui.dBegin.datepicker('getDate')).startOf('month').toDate())
        else
          @ui.reportPeriod.data 'isLinked', false

      @ui.dBegin.data('oldDate', @ui.dBegin.datepicker('getDate'))

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

    changeRepeatType: (e)->
      option = $(this.ui.repeatType.select2('data').element).data()
      # @formatter:off
      switch +@ui.repeatType.select2('val')
        when 0
          # None
          @ui._weekDays.hide()
          @ui._monthDays.hide()
          @ui._end.hide()
        when 1
          # Weekly
          @ui._weekDays.show()
          @ui._monthDays.hide()
          @ui._end.show()
        when 2
          # Monthly
          @ui._weekDays.hide()
          @ui._monthDays.show()
          @ui._end.show()
        when 3, 4
          # Q, Yearly
          @ui._weekDays.hide()
          @ui._monthDays.hide()
          @ui._end.show()
        else
          alert "Unknown 'repeatType': #{@ui.repeatType.select2('val')}"
      # @formatter:on

    changeEndType: (e)->
      # @formatter:off
      switch +@ui.endType.select2('val')
        when 0
          # None
          @ui._repeatCount.hide()
          @ui._dEnd.hide()
        when 1
          # After
          @ui._repeatCount.show()
          @ui._dEnd.hide()
        when 2
          # on date
          @ui._repeatCount.hide()
          @ui._dEnd.show()
        else
          alert "Unknown 'repeatType': #{repeatType}"
      # @formatter:on


    getTitle: ->
      "Запланированная операция &gt; #{if @model.isNew() then 'Добавление' else 'Редактирование'}"

    onRender: ->
      @updateMoneyPrecision(@model.get('idMoney'))
      @ui.dBegin.datepicker('setDate', moment(@model.get('dBegin'), 'YYYY-MM-DD').toDate())

      @ui.reportPeriod
      .datepicker('setDate', moment(@model.get('reportPeriod'), 'YYYY-MM-DD').toDate())

      @ui.contractor.select2
        placeholder: 'Выберите контрагента'
        allowClear: true
      @ui.contractor.select2('val', @model.get('idContractor'))

      @ui.account.select2
        placeholder: 'Выберите счет'
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
          # TODO уйти от s
          el.search.val s.strLeft(el.data().text, '&rarr;').trim()
          el.updateResults false
      .on 'change', ->
        # for jQuery Validation Plugin
        $(@).trigger 'blur'

      @ui.category.select2('val', @model.get('idCategory'))


      @ui.sum.val @model.get('sum')

      @ui.quantity.val @model.get('quantity')

      @ui.note.val @model.get('note')

      @ui.operationNote.val @model.get('operationNote')

      @ui.operationTags.select2
        tokenSeparators: [',']
        tags: CashFlow.entities.tags.map (tag) ->
          tag.get('name')
      @ui.operationTags.select2('val', @model.get('operationTags'))

      @ui.colorMark
      .filter('[value=' + @model.get('colorMark') + ']')
      .prop('checked', true)
      .parent()
      .addClass('active')

      @ui.repeatType.select2
        minimumResultsForSearch: Infinity

      @ui.repeatType.select2('val', @model.get('repeatType')).change()

      @ui.monthDays.select2()

      if @model.get('repeatType') is 1
        _.each @model.get('repeatDays'), (day) =>
          @ui.weekDays
          .filter('[value=' + day + ']')
          .prop('checked', true)
          .parent()
          .addClass('active')

      if @model.get('repeatType') is 2
        @ui.monthDays.select2('val', @model.get('repeatDays'))

      @ui.endType.select2
        minimumResultsForSearch: Infinity

      endType = @model.get('endType') || 0
      @ui.endType.select2('val', endType).change()

      if endType is 1 and @model.get('repeatCount')
        @ui.repeatCount.val @model.get('repeatCount')

      if endType is 2 and @model.get('dEnd')
        @ui.dEnd.datepicker('setDate', moment(@model.get('dEnd'), 'YYYY-MM-DD').toDate())

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
          dBegin_:
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
          monthDays:
            required:
              param: true
              depends: =>
                +@ui.repeatType.select2('val') is 2
          repeatCount:
            required:
              param: true
              depends: =>
                +@ui.endType.select2('val') is 1
            number:
              param: true
              depends: =>
                +@ui.endType.select2('val') is 1
            moreThan:
              param: 1
              depends: =>
                +@ui.endType.select2('val') is 1
          dEnd_:
            required:
              param: true
              date: true
              depends: =>
                +@ui.endType.select2('val') is 2
            dateMoreThan:
              param: moment(@ui.dBegin.datepicker('getDate')).format('DD.MM.YYYY')
              depends: =>
                +@ui.endType.select2('val') is 2
        messages:
          account:
            required: 'Пожалуйста, выберите счет'
          category:
            required: 'Пожалуйста, выберите категорию'
          dBegin_:
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
          monthDays:
            required: 'Пожалуйста, укажите числа месяца'
          repeatCount:
            required: 'Пожалуйста, укажите количество повторений'
            number: 'Пожалуйста, введите в поле "Количество повторений" число'
            moreThan: 'Количество повторений должно быть больше 1'
          dEnd_:
            required: 'Пожалуйста, укажите дату окончания',
            dateMoreThan: 'Пожвлуйста, укажите дату окончания больше даты начала'

      @ui.form.submit (e) ->
        e.preventDefault()

    onShow: ->
      #      if (@model.get('permit') & 3) isnt 3 and not @model.isNew()
      #        @$('.form-control, [type=radio], [type=checkbox]').prop('disabled', true)
      #
      #        @ui.account.select2 'enable', false
      #        @ui.category.select2 'enable', false
      #        @ui.tags.select2 'enable', false
      #        @ui.unit.select2 'enable', false
      #        @ui.money.select2 'enable', false
      #        @ui.btnAddCategory.prop 'disabled', true
      #        @ui.btnSave.prop 'disabled', true
      #        @ui.btnMore.prop 'disabled', true
      _.defer =>
        if @ui[@config.focusField].hasClass 'select2'
          @ui[@config.focusField].select2('focus')
        else
          @ui[@config.focusField].focus()

    serialize: ->
      repeatType = +@ui.repeatType.select2('val')

      result =
        sign: numToJSON @$('input[name=sign]:checked').val()
        dBegin: moment(@ui.dBegin.datepicker('getDate')).format('YYYY-MM-DD')
        reportPeriod: moment(@ui.reportPeriod.datepicker('getDate')).format('YYYY-MM-DD')
        idContractor: numToJSON @ui.contractor.select2('data').id
        idAccount: numToJSON @ui.account.select2('data').id
        idCategory: numToJSON @ui.category.select2('data').id
        sum: numToJSON @ui.sum.val()
        idMoney: numToJSON @ui.money.data 'idMoney'
        quantity: numToJSON @ui.quantity.val()
        idUnit: numToJSON @ui.unit.data 'idUnit'
        note: @ui.note.val()
        repeatType: numToJSON repeatType
        operationNote: @ui.operationNote.val()
        operationTags: @ui.operationTags.select2 'val'
        colorMark: @ui.colorMark.filter(':checked').val()


      switch repeatType
        when 0
        # None
          _.extend result,
            repeatDays: null
            endType: null
            repeatCount: null
            dEnd: null
        when 1, 2, 3, 4
          endType = +@ui.endType.select2 'val'

          switch repeatType
            when 1
            # Weekly
              _.extend result,
                repeatDays: _.map @ui.weekDays.filter(':checked'), (item) ->
                  parseInt item.value
            when 2
            # Monthly
              _.extend result,
                repeatDays: _.map @ui.monthDays.select2('val'), (item) ->
                  parseInt item
            when 3, 4
            # Quarterly, Yearly
              _.extend result,
                repeatDays: null

          # endType
          _.extend result,
            endType: numToJSON endType

          switch endType
            when 0
              _.extend result,
                repeatCount: null
                dEnd: null
            when 1
              _.extend result,
                repeatCount: numToJSON @ui.repeatCount.val()
                dEnd: null
            when 2
              _.extend result,
                repeatCount: null
                dEnd: moment(@ui.dEnd.datepicker('getDate')).format('YYYY-MM-DD')
            else
              alert "Unknown 'endType'"
        else
          alert "Unknown 'repeatType'"
      result

    getPatch: ->
      compareJSON @model.toJSON(), @serialize()

    cancel: ->
      @trigger 'form:cancel'

    save: (e) ->
      e.preventDefault()
      return if not @ui.form.valid()

      if @ui.repeatType.val() is '1' and @ui.weekDays.filter(':checked').size() is 0
        showError 'Пожалуйста, укажите дни недели'
        return

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

    onDestroy: ->
      @ui.contractor.select2 'destroy'
      @ui.account.select2 'destroy'
      @ui.category.select2 'destroy'
      @ui.monthDays.select2 'destroy'
      @ui.operationTags.select2 'destroy'
      @ui.repeatType.select2 'destroy'
      @ui.endType.select2 'destroy'
