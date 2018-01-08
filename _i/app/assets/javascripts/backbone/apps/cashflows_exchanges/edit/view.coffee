@CashFlow.module 'CashFlowsExchangesApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Exchange extends App.Views.Layout
    template: 'cashflows_exchanges/edit/layout'

    dialog: ->
      title: @getTitle()
      keyboard: false
      backdrop: 'static'

    form:
      focusFirstInput: false
      syncing: true

    ui:
      form: 'form'
      dExchange: '[name=dExchange]'
      reportPeriod: '[name=reportPeriod]'

      accountFrom: '[name=accountFrom]'
      sumFrom: '[name=sumFrom]'
      moneyFrom: 'span[name=moneyFrom]'

      accountTo: '[name=accountTo]'
      sumTo: '[name=sumTo]'
      moneyTo: 'span[name=moneyTo]'

      isFee: '[name=isFee]'

      feeFieldSet: '[name=feeFieldSet]'
      fee: '[name=fee]'
      moneyFee: 'span[name=moneyFee]'
      accountFee: '[name=accountFee]'

      note: '[name=note]'
      tags: '[name=tags]'

    events:
      'click .btn[name=btnSave]': 'save'
      'click .btn[name=btnCancel]': 'cancel'
      'change @ui.isFee': 'changeIsFee'
      'changeDate @ui.dExchange': 'changeDateDExchange'
      'keydown @ui.sumFrom': 'keyPress'
      'focusout @ui.sumFrom': 'recalculateSumFrom'
      'keydown @ui.sumTo': 'keyPress'
      'focusout @ui.sumTo': 'recalculateSumTo'
      'keydown @ui.fee': 'keyPress'
      'focusout @ui.fee': 'recalculateSumFee'
      'click div[name=moneyFrom] ul.dropdown-menu li': 'selectMoneyFrom'
      'click div[name=moneyTo] ul.dropdown-menu li': 'selectMoneyTo'
      'click div[name=moneyFee] ul.dropdown-menu li': 'selectMoneyFee'


    initialize: (options = {}) ->
      options.config or= {}

      _.defaults options.config,
        focusField: 'accountFrom'

      @config = options.config

    updateMoneyFromPrecision: (idMoney) ->
      money = App.entities.moneys.findWhere({idMoney})
      @precisionFrom = if money then money.get('precision') else 2

    updateMoneyToPrecision: (idMoney) ->
      money = App.entities.moneys.findWhere({idMoney})
      @precisionTo = if money then money.get('precision') else 2

    updateMoneyFeePrecision: (idMoney) ->
      money = App.entities.moneys.findWhere({idMoney})
      @precisionFee = if money then money.get('precision') else 2

    recalculateSumFrom: (e) ->
      $el = $(e.target)
      value = _.trim $el.val()
      if value isnt ''
        value = value.replace(/[,ю]/g, '.').replace(/\s/g, '')
        try
          sum = eval(value)
        catch
          undefined

        @ui.sumFrom.val(round(sum, @precisionFrom)) if _.isNumber(sum)


    recalculateSumTo: (e) ->
      $el = $(e.target)
      value = _.trim $el.val()
      if value isnt ''
        value = value.replace(/[,ю]/g, '.').replace(/\s/g, '')
        try
          sum = eval(value)
        catch
          undefined

        @ui.sumTo.val(round(sum, @precisionTo)) if _.isNumber(sum)

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
        @recalculateSumFrom(e)
        @recalculateSumTo(e)
        @recalculateSumFee(e)


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



#    selectMoneyFrom: (e) ->
#      e.preventDefault()
#      $el = $(e.target)
#      li = $(e.currentTarget)
#      li.siblings().removeClass('active').end().addClass('active')
#
#      @ui.moneyFrom.text(li.data('text')).data('idMoney', li.data('idMoney'))

    selectMoneyFrom: (e) ->
      e.preventDefault()
      li = $(e.currentTarget)
      li.siblings().removeClass('active').end().addClass('active')

      @ui.moneyFrom.text(li.data('text')).data('idMoney', li.data('idMoney'))
      @updateMoneyFromPrecision(li.data('idMoney'))


    selectMoneyTo: (e) ->
      e.preventDefault()
      li = $(e.currentTarget)
      li.siblings().removeClass('active').end().addClass('active')

      @ui.moneyTo.text(li.data('text')).data('idMoney', li.data('idMoney'))
      @updateMoneyToPrecision(li.data('idMoney'))


    selectMoneyFee: (e)->
      e.preventDefault()
      li = $(e.currentTarget)
      li.siblings().removeClass('active').end().addClass('active')

      @ui.moneyFee.text(li.data('text')).data('idMoney', li.data('idMoney'))
      @updateMoneyFeePrecision(li.data('idMoney'))

    getTitle: ->
      if @model.get('idPlan')
        "Добавление запланированного обмена"
      else
        "#{if @model.isNew() then 'Добавление' else 'Редактирование'} обмена валюты"


    serialize: ->
      result =
        dExchange: moment(@ui.dExchange.datepicker('getDate')).format('YYYY-MM-DD')
        reportPeriod: moment(@ui.reportPeriod.datepicker('getDate')).format('YYYY-MM-DD')
        idAccountFrom: numToJSON @ui.accountFrom.select2('data').id
        sumFrom: numToJSON @ui.sumFrom.val()
        idMoneyFrom: numToJSON @ui.moneyFrom.data 'idMoney'
        idAccountTo: numToJSON @ui.accountTo.select2('data').id
        sumTo: numToJSON @ui.sumTo.val()
        idMoneyTo: numToJSON @ui.moneyTo.data 'idMoney'
        note: @ui.note.val()
        tags: @ui.tags.select2 'val'

      if @ui.isFee.prop('checked')
        _.extend result,
          idAccountFee: numToJSON @ui.accountFee.select2('data').id
          fee: numToJSON @ui.fee.val()
          idMoneyFee: numToJSON @ui.moneyFee.data 'idMoney'
      else
        _.extend result,
          idAccountFee: null
          fee: null
          idMoneyFee: null

      result


    getPatch: ->
      compareJSON @model.toJSON(), @serialize()


    save: (e) ->
      e.preventDefault()
      return if not @ui.form.valid()

      if @ui.moneyTo.data('idMoney') is @ui.moneyFrom.data('idMoney')
        showError 'Пожалуйста, укажите валюту покупки отличную от валюты продажи'
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


    cancel: ->
      @trigger 'form:cancel'


    changeIsFee: ->
      if @ui.isFee.prop('checked')
        @ui.feeFieldSet.show()
      else
        @ui.feeFieldSet.hide()


    onRender: ->
      @updateMoneyFromPrecision(@model.get('idMoneyFrom'))
      @updateMoneyToPrecision(@model.get('idMoneyTo'))
      @updateMoneyFeePrecision(@model.get('idMoneyFee'))

      @ui.dExchange.datepicker('setDate', moment(@model.get('dExchange'), 'YYYY-MM-DD').toDate())
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

      @ui.sumFrom.val @model.get('sumFrom')

      @ui.sumTo.val @model.get('sumTo')

      @ui.isFee
      .prop('checked', @model.get('idAccountFee'))
      .change()

      @ui.accountFee.select2
        placeholder: 'Выберите счет'
      @ui.accountFee.select2('val', @model.get('idAccountFee'))

      # for jQuery Validation Plugin
      @ui.accountFee.on 'change', ->
        $(@).trigger 'blur'

      @ui.fee.val @model.get('fee')

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
          accountTo:
            required: true
          sumTo:
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
            required: 'Пожалуйста, выберите счет, с которого продаете валюту'
          sumFrom:
            required: 'Пожалуйста, укажите сумму продажи'
            number: 'Пожалуйста, введите в поле "Продажа" число'
            moreThan: 'Сумма продажи должна быть больше 0'
          accountTo:
            required: 'Пожалуйста, выберите счет, на который покупаете валюту'
          sumTo:
            required: 'Пожалуйста, укажите сумму покупки'
            number: 'Пожалуйста, введите в поле "Покупка" число'
            moreThan: 'Сумма покупки должна быть больше 0'
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
