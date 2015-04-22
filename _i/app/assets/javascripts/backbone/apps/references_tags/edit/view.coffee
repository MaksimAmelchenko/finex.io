@CashFlow.module 'ReferencesTagsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Tag extends App.Views.Layout
    template: 'references_tags/edit/layout'

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
      "Тег &gt; #{if @model.isNew() then 'Добавление' else 'Редактирование'}"

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
            maxlength: 30
            required: true
        messages:
          name:
            maxlength: 'Пожалуйста, введите не более 30 символов'
            required: 'Пожалуйста, введите наименование тега'

      @ui.form.submit (e) ->
        e.preventDefault()
