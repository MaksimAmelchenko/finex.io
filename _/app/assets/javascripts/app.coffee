do ($) ->
  ui =
    btnDemoSignIn: $('[name=btnDemoSignIn]')

  ui.btnDemoSignIn.on 'click', ->

    ui.btnDemoSignIn.amkDisable()
    $.ajax
      url: '{server}/v1/signin'
      type: 'POST'
      contentType: 'application/json'
      dataType: 'json'
      timeout: 5000
      data: JSON.stringify
        login: 'john@finex.io'
        password: 'kd9T2QHjSb5Y'
      success: (res, textStatus, jqXHR)->
        sessionStorage.setItem('authorization', res.authorization)
        window.location.href = '/i/'
      error: (jqXHR, textStatus, errorThrown)->
        ui.btnDemoSignIn.amkEnable()

        if jqXHR.responseJSON
          error = jqXHR.responseJSON.error
          message = error.message
        else
          message = 'Нет связи с сервером. Попробуйте, пожалуйста, позже'

        alert message

    ga?('send', 'event', 'button', 'click', 'demo')

  $(document).on 'popup_opened.social-likes', (event, service) ->
    ga?('send', 'social', service, 'share', location.href)

