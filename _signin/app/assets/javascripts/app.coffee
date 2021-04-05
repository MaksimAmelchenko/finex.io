do ($) ->
  ui =
    form: $('form')
    email: $('[name=email]')
    password: $('[name=password]')
    btnSignIn: $('[name=btnSignIn]')

  ui.form.submit (e) ->
    e.preventDefault()

  ui.email.focus()

  ui.form.validate
    highlight: (element) ->
      $(element).closest('.form-group').addClass('has-error')
    unhighlight: (element) ->
      $(element).closest('.form-group').removeClass('has-error')
    errorElement: 'span',
    errorClass: 'help-block',
    rules:
      email:
        required: true,
      password:
        required: true
    messages:
      email:
        required: 'Пожалуйста, введите логин',
      password:
        required: 'Пожалуйста, введите свой пароль'


  ui.btnSignIn.on 'click', (e) ->
    e.preventDefault()

    return if not ui.form.valid()

    ui.btnSignIn.amkDisable()

    $.ajax
      url: '{server}/v2/sign-in'
      type: 'POST'
      contentType: 'application/json'
      dataType: 'json'
      data: JSON.stringify
        username: ui.email.val()
        password: ui.password.val()
      success: (res, textStatus, jqXHR)->
        ui.btnSignIn.amkEnable()
        sessionStorage.setItem('authorization', res.authorization)
        window.location.href = '/i/'
      error: (jqXHR, textStatus, errorThrown)->
        ui.btnSignIn.amkEnable()

        if jqXHR.responseJSON
          error = jqXHR.responseJSON.error
          message = error.message
        else
          message = 'Нет связи с сервером. Попробуйте, пожалуйста, позже'

        element = ui.password
        .attr('aria-describedby', 'password-error')
        .closest('.form-group')
        .addClass('has-error')

        if $('#password-error').length
          $('#password-error').html(message).show()
        else
          element.append "<span id='password-error' class='help-block'>#{message}</span>"
