do ($) ->
  ui =
    form: $('form')
    password: $('[name=password]')
    error: $('[name=error]')
    btnReset: $('[name=btnReset]')

  ui.form.validate
    highlight: (element) ->
      $(element).closest('.form-group').addClass('has-error')
    unhighlight: (element) ->
      $(element).closest('.form-group').removeClass('has-error')
    errorElement: 'span',
    errorClass: 'help-block',
    rules:
      password:
        required: true
        minlength: 5
    messages:
      password:
        required: 'Пожалуйста, введите пароль'

  token = getParam('token')

  ui.form.submit (e) ->
    e.preventDefault()

  if token
    ui.btnReset.on 'click', ->
      ui.error.hide()
      return if not ui.form.valid()

      ui.btnReset.amkDisable()

      $.ajax
        url: '{server}/v2/reset-password/confirm'
        type: 'POST'
        contentType: 'application/json'
        dataType: 'json'
        data: JSON.stringify
          token: getParam('token')
          password: ui.password.val()
        success: (res, textStatus, jqXHR)->
          $('.panel-body').html """
            <p>
              Пароль изменен
            </p>
            <a href="/signin/" name="btnSignIn" class="btn btn-primary">Войти</a>
          """
        error: (jqXHR, textStatus, errorThrown)->
          ui.btnReset.amkEnable()
          if jqXHR.responseJSON
            error = jqXHR.responseJSON.error
            message = error.message
            message = 'Во время смены пароля произошла ошибка. Пожалуйста, попробуйте, позже' unless message
          else
            message = 'Нет связи с сервером. Попробуйте, пожалуйста, позже'

          ui.error
          .html message
          .show()
#          element = ui.password
#          .attr('aria-describedby', 'password-error')
#          .closest('.form-group')
#          .addClass('has-error')
#
#          if $('#password-error').length
#            $('#password-error').html(message).show()
#          else
#            element.append "<span id='password-error' class='help-block'>#{message}</span>"

  else
    $('.panel').addClass 'panel-danger'
    $('.panel-body').html 'Неверный запрос'
