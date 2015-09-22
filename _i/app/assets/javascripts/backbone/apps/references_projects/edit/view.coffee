@CashFlow.module 'ReferencesProjectsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Project extends App.Views.Layout
    template: 'references_projects/edit/layout'

    ui:
      name: '[name=name]'
#      currencies: '[name=currencies]'
      note: '[name=note]'
      writers: '[name=writers]'
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

    initialize: (options = {}) ->
      @config = options.config

    getTitle: ->
      "Проект &gt; #{if @model.isNew() then 'Добавление' else 'Редактирование'}"

    serialize: ->
      name: @ui.name.val()
#      currencies: _.map @ui.currencies.select2('val'), (item) ->
#        parseInt item
      note: @ui.note.val()
      writers: _.map @ui.writers.select2('val'), (item) ->
        parseInt item

    getPatch: ->
      compareJSON @model.toJSON(), @serialize()

    save: (e) ->
      e.preventDefault()
      return if not @ui.form.valid()
      data = @serialize()
#      if data.currencies.length is 0
#        @ui.currencies.addClass 'has-error'
#        showError 'Пожалуйста, выберите хотя бы одну валюту'
#        return

      if @model.isNew()
        @model.save data,
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

#      @ui.currencies.select2
#        multiple: true,
#        placeholder: ''
#        data: CashFlow.entities.currencies.map (currency) ->
#          id: currency.id
#          text: currency.get('name') + ' [' + currency.get('code') + ']'
#      @ui.currencies.select2('val', @model.get('currencies'))
#
#      @ui.currencies.on 'change', ->
#        $(@).removeClass 'has-error'

      users = _.filter(CashFlow.entities.users.toJSON(), (user) ->
        return user.idUser isnt App.entities.profile.get('idUser'))

      @ui.writers.select2
        multiple: true,
        placeholder: ''
        data: _.map(users, (user)->
          id: user.idUser
          text: user.name
        )
      @ui.writers.select2('val', @model.get('writers'))

      @ui.note.val @model.get('note')

      @ui.form.validate
        rules:
          name:
            maxlength: 30
            required: true
        messages:
          name:
            maxlength: 'Пожалуйста, введите не более 30 символов'
            required: 'Пожалуйста, введите название проекта'

      @ui.form.submit (e) ->
        e.preventDefault()

    onDestroy: ->
#      @ui.currencies.select2 'destroy'
      @ui.writers.select2 'destroy'
