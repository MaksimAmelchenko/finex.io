@CashFlow.module 'CashFlowsDebtsApp.EditDetail', (EditDetail, App, Backbone, Marionette, $, _) ->
  class EditDetail.Detail extends App.Views.Layout
    template: 'cashflows_debts/edit_detail/layout'

    dialog: ->
      title: @getTitle()
      keyboard: false
      backdrop: 'static'

    form:
      focusFirstInput: false

    ui:
      dDebtDetail: '[name=dDebtDetail]'
      reportPeriod: '[name=reportPeriod]'
      account: '[name=account]'
      category: '[name=category]'
      sum: '[name=sum]'
      money: '[name=money]'
      note: '[name=note]'
      tags: '[name=tags]'
      form: 'form'

    events:
      'click .btn[name=btnSave]': 'save'
      'click .btn[name=btnCancel]': 'cancel'
      'changeDate @ui.dDebtDetail': 'changeDateDDebtDetail'
      'keydown @ui.sum': 'keyPress'
      'focusout @ui.sum': 'recalculateSum'

    initialize: (options = {}) ->
      options.config or= {}

      _.defaults options.config,
        focusField: 'account'

      @config = options.config

    recalculateSum: ->
      value = _.trim @ui.sum.val()
      if value isnt ''
        value = value.replace(/[,ю]/g, '.').replace(/\s/g, '')
        try
          sum = eval(value)
        catch
          undefined

        @ui.sum.val(round(sum, 2)) if _.isNumber(sum)

    keyPress: (e) ->
      code = e.keyCode || e.which
      if code is 13
        @recalculateSum()

    changeDateDDebtDetail: ->
      # reportPeriod is dependence from dIEDetail unless it does not changed
      if @ui.reportPeriod.data('isLinked') and moment(@ui.reportPeriod.datepicker('getDate')).isValid()
        oldDate = @ui.dDebtDetail.data('oldDate') || @ui.dDebtDetail.datepicker('getDate')

        if moment(oldDate).format('YYYYMM') is moment(@ui.reportPeriod.datepicker('getDate')).format('YYYYMM')
          if moment(oldDate).format('YYYYMM') isnt moment(@ui.dDebtDetail.datepicker('getDate')).format('YYYYMM')
            @ui.reportPeriod.datepicker('setDate', moment(@ui.dDebtDetail.datepicker('getDate')).startOf('month').toDate())
        else
          @ui.reportPeriod.data 'isLinked', false

      @ui.dDebtDetail.data('oldDate', @ui.dDebtDetail.datepicker('getDate'))


    getTitle: ->
      "Детализация долга &gt; #{if @model.isNew() then 'Добавление' else 'Редактирование'}"

    onRender: ->
      @ui.dDebtDetail.datepicker('setDate', moment(@model.get('dDebtDetail'), 'YYYY-MM-DD').toDate())
      @ui.reportPeriod.datepicker('setDate', moment(@model.get('reportPeriod'), 'YYYY-MM-DD').toDate())

      @ui.account.select2
        placeholder: 'Выберите счет'
      @ui.account.select2('val', @model.get('idAccount'))
      # for jQuery Validation Plugin
      @ui.account.on 'change', ->
        $(@).trigger 'blur'

      @ui.category.select2
        placeholder: 'Выберите категорию'
      @ui.category.select2('val', @model.get('idCategory'))
      # for jQuery Validation Plugin
      @ui.category.on 'change', ->
        $(@).trigger 'blur'

      @ui.sum.val @model.get('sum')

      @ui.money.select2()
      @ui.money.select2 'val', @model.get('idMoney')

      @ui.note.val @model.get('note')

      @ui.tags.select2
        tokenSeparators: [',']
        tags: CashFlow.entities.tags.map (tag) ->
          tag.get('name')

      @ui.tags.select2('val', @model.get('tags'))

      @ui.form.validate
        onfocusout: false
        rules:
          dDebtDetail_:
            required: true
          reportPeriod_:
            required: true
          category:
            required: true
          account:
            required: true
          sum:
            required: true
            number: true
            moreThan: 0
          money:
            required: true
        messages:
          dDebtDetail_:
            required: 'Пожалуйста, укажите дату',
          reportPeriod_:
            required: 'Пожалуйста, укажите отчетный период',
          account:
            required: 'Пожалуйста, выберите счет'
          category:
            required: 'Пожалуйста, выберите категорию'
          sum:
            required: 'Пожалуйста, укажите сумму'
            number: 'Пожалуйста, введите в поле "Сумма" число'
            moreThan: 'Сумма должна быть больше 0'
          money:
            required: 'Пожалуйста, укажите валюту'

      @ui.form.submit (e) ->
        e.preventDefault()


    cancel: ->
      @trigger 'form:cancel'


    onShow: ->
      _.defer =>
        if @ui[@config.focusField].hasClass 'select2'
          @ui[@config.focusField].select2('focus')
        else
          @ui[@config.focusField].focus()

    serialize: ->
      sign: numToJSON @$('input[name=sign]:checked').val()
      dDebtDetail: moment(@ui.dDebtDetail.datepicker('getDate')).format('YYYY-MM-DD')
      reportPeriod: moment(@ui.reportPeriod.datepicker('getDate')).format('YYYY-MM-DD')
      idAccount: numToJSON @ui.account.select2('data').id
      idCategory: numToJSON @ui.category.select2('data').id
      sum: numToJSON @ui.sum.val()
      idMoney: numToJSON @ui.money.select2('data').id
      note: @ui.note.val()
      tags: @ui.tags.select2 'val'

    getPatch: ->
      compareJSON @model.toJSON(), @serialize()

    save: (e) ->
      e.preventDefault()
      return if not @ui.form.valid()

      @model.set @serialize()
      @trigger 'form:after:save', @model

    onDestroy: ->
      @ui.account.select2 'destroy'
      @ui.category.select2 'destroy'
      @ui.money.select2 'destroy'
      @ui.tags.select2 'destroy'
