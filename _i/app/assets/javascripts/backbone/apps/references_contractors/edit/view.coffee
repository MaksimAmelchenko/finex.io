@CashFlow.module 'ReferencesContractorsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Contractor extends App.Views.Layout
    template: 'references_contractors/edit/layout'

    ui:
      name: '[name=name]'
      note: '[name=note]'
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
      "Контрагент &gt; #{if @model.isNew() then 'Добавление' else 'Редактирование'}"

    serialize: ->
      name: @ui.name.val()
      note: @ui.note.val()

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
      #      @ui.isEnabled.prop('checked', @model.get('isEnabled'))
      @ui.note.val @model.get('note')

      @ui.form.validate
        rules:
          name:
            maxlength: 100
            required: true
        messages:
          name:
            maxlength: 'Пожалуйста, введите не более 100 символов'
            required: 'Пожалуйста, введите название контрагента'

      @ui.form.submit (e) ->
        e.preventDefault()
