@CashFlow.module 'ProfileApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Profile extends App.Views.Layout
    template: 'profile/edit/layout'
    className: 'container-fluid'

    ui:
      form: 'form'
      email: '[name=email]'
      isChangePassword: '[name=isChangePassword]'
      passwordFieldSet: '[name=passwordFieldSet]'
      newPassword: '[name=newPassword]'
      name: '[name=name]'
      project: '[name=project]'
      currencyRateSource: '[name=currencyRateSource]'
      password: '[name=password]'

    form:
      focusFirstInput: true

    events:
      'click .btn[name=btnSave]': 'save'
      'change @ui.isChangePassword': 'changeIsChangePassword'

    modelEvents:
      'change': 'onRender'

    initialize: (options = {}) ->
      @config = options.config

    serialize: ->
      result =
        email: @ui.email.val()
        isChangePassword: @ui.isChangePassword.prop('checked')
        name: @ui.name.val()
        idProject: numToJSON @ui.project.val()
        idCurrencyRateSource: numToJSON @ui.currencyRateSource.val()
        password: @ui.password.val()

      if @ui.isChangePassword.prop('checked')
        _.extend result,
          newPassword: @ui.newPassword.val()

      result

    getPatch: ->
      compareJSON @model.toJSON(), @serialize()

    save: ->
      return if not @ui.form.valid()
      patch = @getPatch()

      if !_.isEmpty patch
        @addOpacityWrapper()
        @model.save patch,
          patch: true
          success: (model, resp, options) =>
            @addOpacityWrapper(false)
            showInfo 'Сохранено'
            @model.unset 'isChangePassword',
              silent: true
            @model.unset 'newPassword',
              silent: true
            @model.unset 'password',
              silent: true
          error: =>
            @addOpacityWrapper(false)


    changeIsChangePassword: ->
      if @ui.isChangePassword.prop('checked')
        @ui.passwordFieldSet.show()
      else
        @ui.passwordFieldSet.hide()

    onRender: ->
      @ui.email.val @model.get('email')
      @ui.isChangePassword.prop('checked', false).change()
      @ui.newPassword.val ''
      @ui.password.val ''
      #      @ui.tz.val @model.get('tz')
      @ui.name.val @model.get('name')

      @ui.project.select2()
      @ui.project.select2('val', @model.get('idProject'))

      @ui.currencyRateSource.select2()
      @ui.currencyRateSource.select2('val', @model.get('idCurrencyRateSource'))

      @ui.form.validate
        rules:
          email:
            required: true
            maxlength: 50
          name:
            required: true
            maxlength: 50
          project:
            required: true
          password:
            required: true
          newPassword:
            minlength: 5
            required:
              depends: =>
                @ui.isChangePassword.prop('checked')
        messages:
          email:
            required: 'Пожалуйста, укажите электронный адрес'
          name:
            required: 'Пожалуйста, укажите свое имя'
          project:
            required: 'Пожалуйста, укажите проект по&#x2010;умолчанию',
          password:
            required: 'Пожалуйста, укажите свой пароль',
          newPassword:
            required: 'Пожалуйста, укажите новый пароль'

      # for jQuery Validation Plugin
      @ui.project.on 'change', ->
        $(@).trigger 'blur'

      @ui.form.submit (e) ->
        e.preventDefault()

    onDestroy: ->
      @ui.project.select2 'destroy'
