@CashFlow.module 'ReferencesAccountsApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Account extends App.Views.Layout
    template: 'references_accounts/edit/layout'

    ui:
      name: '[name=name]'
      accountType: '[name=accountType]'
      isEnabled: '[name=isEnabled]'
      note: '[name=note]'
      readers: '[name=readers]'
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

#    modelEvents:
#      'change': 'render'

    initialize: (options = {}) ->
      @config = options.config

    getTitle: ->
      "Счет &gt; #{if @model.isNew() then 'Добавление' else 'Редактирование'}"

    serialize: ->
      name: @ui.name.val()
      idAccountType: numToJSON @ui.accountType.select2('data').id
      isEnabled: @ui.isEnabled.prop('checked')
      note: @ui.note.val()
      readers: _.map @ui.readers.select2('val'), (item) ->
        parseInt item
      writers: _.map @ui.writers.select2('val'), (item) ->
        parseInt item

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

      @ui.accountType.select2()
      @ui.accountType.select2('val', @model.get('idAccountType'))

      users = _.filter(CashFlow.entities.users.toJSON(), (user) ->
        return user.idUser isnt App.entities.profile.get('idUser'))

      @ui.readers.select2
        allowClear: true
        multiple: true,
        placeholder: ''
        data: _.map(users, (user)->
          id: user.idUser
          text: user.name
        )
      @ui.readers.select2('val', @model.get('readers'))

      @ui.writers.select2
        allowClear: true
        multiple: true,
        placeholder: ''
        data: _.map(users, (user)->
          id: user.idUser
          text: user.name
        )
      @ui.writers.select2('val', @model.get('writers'))


      @ui.isEnabled.prop('checked', @model.get('isEnabled'))
      @ui.note.val @model.get('note')

      @ui.form.validate
        rules:
          name:
            maxlength: 100
            required: true
          accountType:
            required: true
        messages:
          name:
            maxlength: 'Пожалуйста, введите не более 100 символов'
            required: 'Пожалуйста, введите наименование счета'
          accountType:
            required: 'Пожалуйста, выберите тип счет'

      @ui.form.submit (e) ->
        e.preventDefault()

    onDestroy: ->
      @ui.accountType.select2 'destroy'
      @ui.readers.select2 'destroy'
      @ui.writers.select2 'destroy'
