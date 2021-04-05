do ($) ->
  ui =
    recoveryPanel: $('[name=recoveryPanel]')
    form: $('form')
    email: $('input[name=email]')
    error: $('[name=error]')
    btnRecovery: $('[name=btnRecovery]')

    confirmPanel: $('[name=confirmPanel]')

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
        email: true
    messages:
      email:
        required: 'Пожалуйста, введите адрес электронной почты'

  ui.form.submit (e) ->
    e.preventDefault()


  ui.btnRecovery.on 'click', ->
    ui.error.hide()
    return if not ui.form.valid()

    #    if not $('#g-recaptcha-response').val()
    #      alert "Пожалуйста, подтвердите, что вы не робот"
    #      return

    ui.btnRecovery.amkDisable()

    $.ajax
      url: '{server}/v2/reset-password'
      type: 'POST'
      contentType: 'application/json'
      dataType: 'json'
      data: JSON.stringify
        email: ui.email.val()
#        recaptcha: $('#g-recaptcha-response').val()
      success: (res, textStatus, jqXHR)->
#        ui.btnSignUp.amkEnable()
        ui.recoveryPanel.remove()
        ui.confirmPanel.show()

      error: (jqXHR, textStatus, errorThrown)->
        ui.btnRecovery.amkEnable()

        if jqXHR.responseJSON
          error = jqXHR.responseJSON.error
          message = error.message
          message = 'Во время запроса произошла ошибка. Попробуйте, пожалуйста, позже' unless message
        else
          message = 'Нет связи с сервером. Попробуйте, пожалуйста, позже'

        ui.error
        .html(message)
        .show()

#        element = ui.email
#        .attr('aria-describedby', 'email-error')
#        .closest('.form-group')
#        .addClass('has-error')
#
#        if $('#email-error').length
#          $('#email-error').html(message).show()
#        else
#          element.append "<span id='email-error' class='help-block'>#{message}</span>"
