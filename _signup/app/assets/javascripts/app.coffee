do ($) ->
  ui =
    signUpPanel: $('[name=signUpPanel]')
    form: $('form')
    name: $('[name=name]')
    email: $('input[name=email]')
    password: $('[name=password]')
    isAcceptTerms: $('[name=isAcceptTerms]')
    error: $('[name=error]')
    btnSignUp: $('[name=btnSignUp]')

    confirmPanel: $('[name=confirmPanel]')
    lblEmail: $('em[name=email]')

  ui.form.validate
    highlight: (element) ->
      $(element).closest('.form-group').addClass('has-error')
    unhighlight: (element) ->
      $(element).closest('.form-group').removeClass('has-error')
    errorPlacement: (error, element) ->
      if (element.parent('.input-group').length or element.prop('type') is 'checkbox' or element.prop('type') is 'radio')
        error.insertAfter(element.parent())
      else
        error.insertAfter(element)
    errorElement: 'span',
    errorClass: 'help-block',
    rules:
      name:
        required: true,
        maxlength: 50
      email:
        required: true,
        email: true
        maxlength: 50
      password:
        required: true
        minlength: 5
#      isAcceptTerms:
#        required: true
    messages:
      name:
        required: 'Пожалуйста, введите свое имя'
      email:
        required: 'Пожалуйста, введите адрес электронной почты'
      password:
        required: 'Пожалуйста, введите пароль'
  #      isAcceptTerms:
  #        required: 'Необходимо принять условия соглашения'


  ui.btnSignUp.on 'click', ->
    ui.error.empty().hide()
    return if not ui.form.valid()

#    if not $('#g-recaptcha-response').val()
#      alert "Пожалуйста, подтвердите, что вы не робот"
#      return

    ui.btnSignUp.amkDisable()
    $.ajax
      url: '{server}/v2/sign-up'
      type: 'POST'
      contentType: 'application/json'
      dataType: 'json'
      data: JSON.stringify
        name: ui.name.val()
        email: ui.email.val()
        password: ui.password.val()
#        isAcceptTerms: ui.isAcceptTerms.prop('checked')
        isAcceptTerms: true
        recaptcha: $('#g-recaptcha-response').val()

      success: (res, textStatus, jqXHR)->
        ui.lblEmail.html ui.email.val()
        ui.signUpPanel.remove()
        ui.confirmPanel.show()

      error: (jqXHR, textStatus, errorThrown)->
#        $('.pls-container').remove()
        grecaptcha.reset()

        ui.btnSignUp.amkEnable()

        if jqXHR.responseJSON
          error = jqXHR.responseJSON.error
          message = error.message || error.devMessage
        else
          message = 'Нет связи с сервером. Попробуйте, пожалуйста, позже'

        ui.error.html(message).show()
