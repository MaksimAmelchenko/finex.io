@CashFlow.module 'ReferencesMoneysApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Money extends App.Views.Layout
    template: 'references_moneys/edit/layout'

    ui:
      currency: '[name=currency]'
      name: '[name=name]'
      symbol: '[name=symbol]'
      isEnabled: '[name=isEnabled]'
      precision: '[name=precision]'
      form: 'form'

    form:
      focusFirstInput: true

    events:
      'click .btn[name=btnSave]': 'save'
      'click .btn[name=btnCancel]': 'cancel'
      'change @ui.currency': 'changeCurrency'

    dialog: ->
      title: @getTitle()
      keyboard: false
      backdrop: 'static'

#    modelEvents:
#      'change': 'render'

    initialize: (options = {}) ->
      @config = options.config

    getTitle: ->
      "Валюта &gt; #{if @model.isNew() then 'Добавление' else 'Редактирование'}"

    changeCurrency: ->
      if @ui.name.val() is '' and @ui.currency.select2('data').id
        @ui.name.val App.entities.currencies.get(@ui.currency.select2('data').id).get('shortName')
        @ui.symbol.val App.entities.currencies.get(@ui.currency.select2('data').id).get('symbol')

    serialize: ->
      idCurrency: numToJSON @ui.currency.select2('data')?.id || null
      name: @ui.name.val()
      symbol: @ui.symbol.val()
      isEnabled: @ui.isEnabled.prop('checked')
      precision: @ui.precision.val()

    getPatch: ->
      compareJSON @model.toJSON(), @serialize()

    save: (e) ->
      e.preventDefault()
      return if not @ui.form.valid()

      if @model.isNew()
        @model.save @serialize(),
          success: (model, resp, options) =>
            @trigger 'form:after:save', @model

      else
        patch = @getPatch()

        if !_.isEmpty patch
          @model.save patch,
            patch: true
            success: (model, resp, options) =>
              @trigger 'form:after:save', @model
        else
          @trigger 'form:after:save', @model


    cancel: ->
      @trigger 'form:cancel'


    onRender: ->
      @ui.currency.select2
        allowClear: true
        placeholder: 'Нет'

      @ui.currency.select2('val', @model.get('idCurrency'))

      @ui.name.val @model.get('name')
      @ui.precision.val @model.get('precision')
      @ui.symbol.val @model.get('symbol')

      @ui.isEnabled.prop('checked', @model.get('isEnabled'))

      @ui.form.validate
        rules:
          name:
            maxlength: 50
            required: true
          symbol:
            maxlength: 10
            required: true
        messages:
          name:
            maxlength: 'Пожалуйста, введите не более 50 символов'
            required: 'Пожалуйста, введите наименование валюты'
          symbol:
            maxlength: 'Пожалуйста, введите не более 10 символов'
            required: 'Пожалуйста, введите символ валюты'

      @ui.form.submit (e) ->
        e.preventDefault()

    onDestroy: ->
      @ui.currency.select2 'destroy'
