do ($) ->
  token = getParam('token')

  if token
    $.ajax
      url: '{server}/v2/sign-up/confirm'
      type: 'POST'
      contentType: 'application/json'
      dataType: 'json'
      data: JSON.stringify
        token: getParam('token')
      success: (res, textStatus, jqXHR)->
        $('.panel-body').html """
          Спасибо, Ваш электронный адрес подтверждён.
          Перейтите <a href="/signin/">сюда</a> для входа
        """

      error: (jqXHR, textStatus, errorThrown)->
        if jqXHR.responseJSON
          error = jqXHR.responseJSON.error
          message = error.message
          message = 'Ошибка на сервере. Попробуйте, пожалуйста, позже' unless message
        else
          message = 'Нет связи с сервером. Попробуйте, пожалуйста, позже'

        $('.panel').addClass('panel-danger')
        $('.panel-body').html message

  else
    $('.panel').addClass('panel-danger')
    $('.panel-body').html 'Неверный запрос'
