@CashFlow.module 'UsersApp.Invite', (Invite, App, Backbone, Marionette, $, _) ->
  class Invite.User extends App.Views.Layout
    template: 'users/invite/layout'

    ui:
      email: '[name=email]'
      message: '[name=message]'
      form: 'form'

    form:
      focusFirstInput: true

    events:
      'click .btn[name=btnInvite]': 'invite'
      'click .btn[name=btnCancel]': 'cancel'

    dialog: ->
      title: 'Пригласить нового пользователя'
      keyboard: false
      backdrop: 'static'

    initialize: (options = {}) ->
      @config = options.config

    serialize: ->
      email: @ui.email.val()
      message: @ui.message.val()

    getPatch: ->
      compareJSON @model.toJSON(), @serialize()

    invite: (e) ->
      e.preventDefault()
      return if not @ui.form.valid()

      App.xhrRequest
        type: 'POST'
        url: "invitations"
        data: JSON.stringify
          email: @ui.email.val()
          message: @ui.message.val()
        success: (res, textStatus, jqXHR) =>
          showInfo 'Приглашение отправлено'

          @trigger 'form:after:save'

    cancel: ->
      @trigger 'form:cancel'

    onRender: ->
      @ui.form.validate
        rules:
          email:
            required: true,
            email: true
            maxlength: 50
        messages:
          email:
            required: 'Пожалуйста, введите адрес электронной почты'

      @ui.form.submit (e) ->
        e.preventDefault()
