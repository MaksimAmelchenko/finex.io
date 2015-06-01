do ($) ->
  $.validator.setDefaults
    ignore: '',
    errorClass: 'has-error',
    highlight: (element, errorClass, validClass) ->
      $(element).parent().addClass(errorClass)
    unhighlight: (element, errorClass, validClass) ->
      $(element).parent().removeClass(errorClass)
    errorPlacement: (error, element) ->
    invalidHandler: (event, validator) ->
      $.each validator.errorList, (i, item) ->
        showError item.message

  $.validator.addMethod 'moreThan', (value, element, param) ->
    @.optional(element) || value > param

  $.validator.addMethod 'lessThan', (value, element, param) ->
    @.optional(element) || value < param

  $.validator.addMethod 'notEqualTo', (value, element, param) ->
    @.optional(element) || value != param

  $.validator.addMethod 'dateMoreThan', (value, element, param) ->
    @.optional(element) ||
      moment(value, 'DD.MM.YYYY').toDate().getTime() >
        moment(param, 'DD.MM.YYYY').toDate().getTime()
