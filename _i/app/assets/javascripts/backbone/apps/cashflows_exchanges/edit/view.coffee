@CashFlow.module 'CashFlowsExchangesApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Exchange extends App.Views.Layout
    template: 'cashflows_exchanges/edit/layout'

    dialog: ->
      title: @getTitle()
      keyboard: false
      backdrop: 'static'

    form:
      focusFirstInput: false

    ui:
      dExchange: '[name=dExchange]'
      reportPeriod: '[name=reportPeriod]'
      accountFrom: '[name=accountFrom]'
      accountTo: '[name=accountTo]'
      sumFrom: '[name=sumFrom]'
      moneyFrom: '[name=moneyFrom]'
      sumTo: '[name=sumTo]'
      moneyTo: '[name=moneyTo]'
      isFee: '[name=isFee]'
      fee: '[name=fee]'
      moneyFee: '[name=moneyFee]'
      accountFee: '[name=accountFee]'
      note: '[name=note]'
      tags: '[name=tags]'
      feeFieldSet: '[name=feeFieldSet]'
      form: 'form'

    events:
      'click .btn[name=btnSave]': 'save'
      'click .btn[name=btnCancel]': 'cancel'
      'change @ui.isFee': 'changeIsFee'
      'changeDate @ui.dExchange': 'changeDateDExchange'
      'keydown @ui.sumFrom': 'keyPress'
      'focusout @ui.sumFrom': 'recalculateSum'
      'keydown @ui.sumTo': 'keyPress'
      'focusout @ui.sumTo': 'recalculateSum'


    initialize: (options = {}) ->
      options.config or= {}

      _.defaults options.config,
        focusField: 'accountFrom'

      @config = options.config

    recalculateSum: (e) ->
      $el = $(e.target)
      value = s.trim($el.val())
      if value isnt ''
        value = s.replaceAll(value, ',', '.')
        value = s.replaceAll(value, ' ', '')
        value = s.replaceAll(value, 'ю', '.')
        try
          sum = eval(value)
        catch

        $el.val(round(sum, 2)) if _.isNumber(sum)

    keyPress: (e) ->
      code = e.keyCode || e.which
      if code is 13
        @recalculateSum(e)

    changeDateDExchange: ->
      # reportPeriod is dependence from dTransfer unless it does not changed
      if @ui.reportPeriod.data('isLinked') and moment(@ui.reportPeriod.datepicker('getDate')).isValid()
        oldDate = @ui.dExchange.data('oldDate') || @ui.dExchange.datepicker('getDate')

        if moment(oldDate).format('YYYYMM') is moment(@ui.reportPeriod.datepicker('getDate')).format('YYYYMM')
          if moment(oldDate).format('YYYYMM') isnt moment(@ui.dExchange.datepicker('getDate')).format('YYYYMM')
            @ui.reportPeriod.datepicker('setDate',
              moment(@ui.dExchange.datepicker('getDate')).startOf('month').toDate())
        else
          @ui.reportPeriod.data 'isLinked', false

      @ui.dExchange.data('oldDate', @ui.dExchange.datepicker('getDate'))


    getTitle: ->
      "Обмен валюты &gt; #{if @model.isNew() then 'Добавление' else 'Редактирование'}"


    serialize: ->
      result =
        dExchange: moment(@ui.dExchange.datepicker('getDate')).format('YYYY-MM-DD')
        reportPeriod: moment(@ui.reportPeriod.datepicker('getDate')).format('YYYY-MM-DD')
        idAccountFrom: numToJSON @ui.accountFrom.select2('data').id
        idAccountTo: numToJSON @ui.accountTo.select2('data').id
        sumFrom: numToJSON @ui.sumFrom.val()
        idMoneyFrom: numToJSON @ui.moneyFrom.val()
        sumTo: numToJSON @ui.sumTo.val()
        idMoneyTo: numToJSON @ui.moneyTo.val()
        isFee: @ui.isFee.prop('checked')
        note: @ui.note.val()
        tags: @ui.tags.select2 'val'

      if @ui.isFee.prop('checked')
        _.extend result,
          idAccountFee: numToJSON @ui.accountFee.select2('data').id
          fee: numToJSON @ui.fee.val()
          idMoneyFee: numToJSON @ui.moneyFee.val()

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
      else
        @ui.feeFieldSet.hide()


    onRender: ->
      @ui.dExchange.datepicker('setDate', moment(@model.get('dExchange'), 'YYYY-MM-DD').toDate())
      @ui.reportPeriod.datepicker('setDate',
        moment(@model.get('reportPeriod'), 'YYYY-MM-DD').toDate())

      @ui.accountFrom.select2
        placeholder: 'Выберете счет'
      @ui.accountFrom.select2('val', @model.get('idAccountFrom'))
      # for jQuery Validation Plugin
      @ui.accountFrom.on 'change', ->
        $(@).trigger 'blur'

      @ui.accountTo.select2
        placeholder: 'Выберете счет'
      @ui.accountTo.select2('val', @model.get('idAccountTo'))
      # for jQuery Validation Plugin
      @ui.accountTo.on 'change', ->
        $(@).trigger 'blur'

      @ui.sumFrom.val @model.get('sumFrom')

      @ui.moneyFrom.select2()
      @ui.moneyFrom.select2 'val', @model.get('idMoneyFrom')

      @ui.sumTo.val @model.get('sumTo')

      @ui.moneyTo.select2()
      @ui.moneyTo.select2 'val', @model.get('idMoneyTo')

      @ui.isFee
      .prop('checked', @model.get('isFee'))
      .change()

      @ui.accountFee.select2
        placeholder: 'Выберете счет'
      @ui.accountFee.select2('val', @model.get('idAccountFee'))

      # for jQuery Validation Plugin
      @ui.accountFee.on 'change', ->
        $(@).trigger 'blur'

      @ui.fee.val @model.get('fee')

      @ui.moneyFee.select2()
      @ui.moneyFee.select2 'val', @model.get('idMoneyFee')

      @ui.note.val @model.get('note')

      @ui.tags.select2
        tokenSeparators: [',']
        tags: CashFlow.entities.tags.map (tag) ->
          tag.get('name')
      @ui.tags.select2('val', @model.get('tags'))

      @ui.form.validate
        onfocusout: false
        rules:
          dExchange_:
            required: true
          reportPeriod_:
            required: true
          accountFrom:
            required: true
          sumFrom:
            required: true
            number: true
            moreThan: 0
          moneyFrom:
            required: true
          accountTo:
            required: true
          sumTo:
            required: true
            number: true
            moreThan: 0
          moneyTo:
            required: true
            notEqualTo: =>
              @ui.moneyFrom.val()
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
          moneyFee:
            required:
              depends: =>
                @ui.isFee.prop('checked')
        messages:
          dExchange_:
            required: 'Пожалуйста, укажите дату',
          reportPeriod_:
            required: 'Пожалуйста, укажите отчетный период',
          accountFrom:
            required: 'Пожалуйста, выберете счет, с которого продаете валюту'
          sumFrom:
            required: 'Пожалуйста, укажите сумму продажи'
            number: 'Пожалуйста, введите в поле "Продажа" число'
            moreThan: 'Сумма продажи должна быть больше 0'
          moneyFrom:
            required: 'Пожалуйста, укажите валюту продажи'
          accountTo:
            required: 'Пожалуйста, выберете счет, на который покупаете валюту'
          sumTo:
            required: 'Пожалуйста, укажите сумму покупки'
            number: 'Пожалуйста, введите в поле "Покупка" число'
            moreThan: 'Сумма покупки должна быть больше 0'
          moneyTo:
            required: 'Пожалуйста, укажите валюту покупки'
            notEqualTo: 'Пожалуйста, укажите валюту покупки отличную от валюты продажи'
          accountFee:
            required: 'Пожалуйста, выберете счет, с которого будет списана комиссия'
          fee:
            required: 'Пожалуйста, укажите комиссию'
            number: 'Пожалуйста, введите в поле "Комиссия" число'
            moreThan: 'Комиссия должна быть больше 0'
          moneyFee:
            required: 'Пожалуйста, укажите валюту комиссии'

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
      @ui.moneyFrom.select2 'destroy'
      @ui.accountTo.select2 'destroy'
      @ui.moneyTo.select2 'destroy'
      @ui.accountFee.select2 'destroy'
      @ui.moneyFee.select2 'destroy'
      @ui.tags.select2 'destroy'
