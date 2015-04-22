do ($) ->
  # container: 'html' - если оставить по-умолчанию body, то будет смещение вверх на высоту заголовка

  $.extend $.fn.datepicker.defaults,
    format: "dd.mm.yyyy"
    keyboardNavigation: false
    todayBtn: "linked"
    language: "ru"
    autoclose: true
    todayHighlight: true
    container: 'html'
