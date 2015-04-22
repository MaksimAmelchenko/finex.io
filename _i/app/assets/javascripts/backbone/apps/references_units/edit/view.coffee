@CashFlow.module 'ReferencesUnitsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Unit extends App.Views.Layout
    template: 'references_units/edit/layout'

    ui:
      name: '[name=name]'
      form: 'form'

    form:
      focusFirstInput: true

    events:
      'click .btn[name=btnSave]': 'save'
      'click .btn[name=btnCancel]': 'cancel'

    dialog: ->
      title: @getTitle()
      keyboard: false
      backdrop: 'static'

#    modelEvents:
#      'change': 'render'

    initialize: (options = {}) ->
      @config = options.config

    getTitle: ->
      "Единица измерения &gt; #{if @model.isNew() then 'Добавление' else 'Редактирование'}"

    serialize: ->
      name: @ui.name.val()

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
      @ui.name.val @model.get('name')

      @ui.form.validate
        rules:
          name:
            maxlength: 20
            required: true
        messages:
          name:
            maxlength: 'Пожалуйста, введите не более 20 символов'
            required: 'Пожалуйста, введите наименование единицы измерения'

      @ui.form.submit (e) ->
        e.preventDefault()

#    onDestroy: ->
#      @ui.accountFrom.select2 'destroy'
