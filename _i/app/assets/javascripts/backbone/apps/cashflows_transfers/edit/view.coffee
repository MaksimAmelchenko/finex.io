@CashFlow.module 'CashFlowsTransfersApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Transfer extends App.Views.Layout
    template: 'cashflows_transfers/edit/layout'

    dialog: ->
      title: @getTitle()
      keyboard: false
      backdrop: 'static'

    form:
      focusFirstInput: false

    ui:
      dTransfer: '[name=dTransfer]'
      reportPeriod: '[name=reportPeriod]'
      accountFrom: '[name=accountFrom]'
      accountTo: '[name=accountTo]'
      sum: '[name=sum]'
      money: 'span[name=money]'

      isFee: '[name=isFee]'
      fee: '[name=fee]'
      moneyFee: 'span[name=moneyFee]'
      accountFee: '[name=accountFee]'
      note: '[name=note]'
      tags: '[name=tags]'
      feeFieldSet: '[name=feeFieldSet]'
      form: 'form'

    events:
      'click .btn[name=btnSave]': 'save'
      'click .btn[name=btnCancel]': 'cancel'
      'change @ui.isFee': 'changeIsFee'
      'changeDate @ui.dTransfer': 'changeDateDTransfer'
      'keydown @ui.sum': 'keyPress'
      'focusout @ui.sum': 'recalculateSum'
      'focusout @ui.fee': 'recalculateSumFee'
      'keydown @ui.fee': 'keyPress'
      'click div[name=money] ul.dropdown-menu li': 'selectMoney'
      'click div[name=moneyFee] ul.dropdown-menu li': 'selectMoneyFee'

    initialize: (options = {}) ->
      options.config or= {}

      _.defaults options.config,
        focusField: 'accountFrom'

      @config = options.config

    updateMoneyPrecision: (idMoney) ->
      money = App.entities.moneys.findWhere({idMoney})
      @precision = if money then money.get('precision') else 2

    updateMoneyFeePrecision: (idMoney) ->
      money = App.entities.moneys.findWhere({idMoney})
      @precisionFee = if money then money.get('precision') else 2

    recalculateSum: ->
      value = _.trim(@ui.sum.val())
      if value isnt ''
        value = value.replace(/[,ю]/g, '.').replace(/\s/g, '')
        try
          sum = eval(value)
        catch
          undefined

        @ui.sum.val(round(sum, @precision)) if _.isNumber(sum)

    recalculateSumFee: (e) ->
      $el = $(e.target)
      value = _.trim $el.val()
      if value isnt ''
        value = value.replace(/[,ю]/g, '.').replace(/\s/g, '')
        try
          sum = eval(value)
        catch
          undefined
        @ui.fee.val(round(sum, @precisionFee)) if _.isNumber(sum)

    keyPress: (e) ->
      code = e.keyCode || e.which
      if code is 13
        @recalculateSum()
        @recalculateSumFee()

    selectMoney: (e)->
      e.preventDefault()
      li = $(e.currentTarget)
      li.siblings().removeClass('active').end().addClass('active')

      @ui.money.text(li.data('text')).data('idMoney', li.data('idMoney'))
      @updateMoneyPrecision(li.data('idMoney'))

    selectMoneyFee: (e)->
      e.preventDefault()
      li = $(e.currentTarget)
      li.siblings().removeClass('active').end().addClass('active')

      @ui.moneyFee.text(li.data('text')).data('idMoney', li.data('idMoney'))
      @updateMoneyFeePrecision(li.data('idMoney'))

    changeDateDTransfer: ->
      # reportPeriod is dependence from dTransfer unless it does not changed
      if @ui.reportPeriod.data('isLinked') and moment(@ui.reportPeriod.datepicker('getDate')).isValid()
        oldDate = @ui.dTransfer.data('oldDate') || @ui.dTransfer.datepicker('getDate')

        if moment(oldDate).format('YYYYMM') is moment(@ui.reportPeriod.datepicker('getDate')).format('YYYYMM')
          if moment(oldDate).format('YYYYMM') isnt moment(@ui.dTransfer.datepicker('getDate')).format('YYYYMM')
            @ui.reportPeriod.datepicker('setDate',
              moment(@ui.dTransfer.datepicker('getDate')).startOf('month').toDate())
        else
          @ui.reportPeriod.data 'isLinked', false

      @ui.dTransfer.data('oldDate', @ui.dTransfer.datepicker('getDate'))


    getTitle: ->
      if @model.get('idPlan')
        "Добавление запланированного перевода"
      else
        "#{if @model.isNew() then 'Добавление' else 'Редактирование'} перевода"


    serialize: ->
      result =
        dTransfer: moment(@ui.dTransfer.datepicker('getDate')).format('YYYY-MM-DD')
        reportPeriod: moment(@ui.reportPeriod.datepicker('getDate')).format('YYYY-MM-DD')
        idAccountFrom: numToJSON @ui.accountFrom.select2('data').id
        idAccountTo: numToJSON @ui.accountTo.select2('data').id
        sum: numToJSON @ui.sum.val()
        idMoney: numToJSON @ui.money.data 'idMoney'
        isFee: @ui.isFee.prop('checked')
        note: @ui.note.val()
        tags: @ui.tags.select2 'val'

      if @ui.isFee.prop('checked')
        _.extend result,
          idAccountFee: numToJSON @ui.accountFee.select2('data').id
          fee: numToJSON @ui.fee.val()
          idMoneyFee: numToJSON @ui.moneyFee.data 'idMoney'

      result

    getPatch: ->
      compareJSON @model.toJSON(), @serialize()

    save: (e) ->
      e.preventDefault()
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


    changeIsFee: ->
      if @ui.isFee.prop('checked')
        @ui.feeFieldSet.show()
#        @ui.moneyFee.val(+@ui.money.val()) if @ui.moneyFee.val() is ""
      else
        @ui.feeFieldSet.hide()


    onRender: ->
      @updateMoneyPrecision(@model.get('idMoney'))
      @updateMoneyFeePrecision(@model.get('idMoneyFee'))
      @ui.dTransfer.datepicker('setDate', moment(@model.get('dTransfer'), 'YYYY-MM-DD').toDate())
      @ui.reportPeriod.datepicker('setDate',
        moment(@model.get('reportPeriod'), 'YYYY-MM-DD').toDate())

      @ui.accountFrom.select2
        placeholder: 'Выберите счет'
      @ui.accountFrom.select2('val', @model.get('idAccountFrom'))

      # for jQuery Validation Plugin
      @ui.accountFrom.on 'change', ->
        $(@).trigger 'blur'

      @ui.accountTo.select2
        placeholder: 'Выберите счет'
      @ui.accountTo.select2('val', @model.get('idAccountTo'))

      # for jQuery Validation Plugin
      @ui.accountTo.on 'change', ->
        $(@).trigger 'blur'

      @ui.sum.val @model.get('sum')

      @ui.isFee
      .prop('checked', @model.get('isFee'))
      .change()

      @ui.fee.val @model.get('fee')

      @ui.accountFee.select2
        placeholder: 'Выберите счет'
      @ui.accountFee.select2('val', @model.get('idAccountFee'))

      # for jQuery Validation Plugin
      @ui.accountFee.on 'change', ->
        $(@).trigger 'blur'

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
          dTransfer_:
            required: true
          reportPeriod_:
            required: true
          accountFrom:
            required: true
          accountTo:
            required: true
            notEqualTo: =>
              @ui.accountFrom.val()
          sum:
            required: true
            number: true
            moreThan: 0
          accountFee:
            required:
              depends: =>
                @ui.isFee.prop('checked')
          fee:
            required:
              depends: =>
                @ui.isFee.prop('checked')
            number:
              param: true
              depends: =>
                @ui.isFee.prop('checked')
            moreThan:
              param: 0
              depends: =>
                @ui.isFee.prop('checked')
        messages:
          dTransfer_:
            required: 'Пожалуйста, укажите дату',
          reportPeriod_:
            required: 'Пожалуйста, укажите отчетный период',
          accountFrom:
            required: 'Пожалуйста, выберите счет, с которого переводите деньги'
          accountTo:
            required: 'Пожалуйста, выберите счет, на который переводите деньги'
            notEqualTo: 'Пожалуйста, выберите счет, отличный от счета, с которого переводите деньги'
          sum:
            required: 'Пожалуйста, укажите сумму перевода'
            number: 'Пожалуйста, введите в поле "Сумма" число'
            moreThan: 'Сумма перевода должна быть больше 0'
          accountFee:
            required: 'Пожалуйста, выберите счет, с которого будет списана комиссия'
          fee:
            required: 'Пожалуйста, укажите комиссию'
            number: 'Пожалуйста, введите в поле "Комиссия" число'
            moreThan: 'Комиссия должна быть больше 0'

      @ui.form.submit (e) ->
        e.preventDefault()


    onShow: ->
      _.defer =>
        if @ui[@config.focusField].hasClass 'select2'
          @ui[@config.focusField].select2('focus')
        else
          @ui[@config.focusField].focus()


    onDestroy: ->
      @ui.accountFrom.select2 'destroy'
      @ui.accountTo.select2 'destroy'
      @ui.accountFee.select2 'destroy'
      @ui.tags.select2 'destroy'

