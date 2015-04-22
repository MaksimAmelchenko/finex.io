do ($) ->
  $.extend $.fn.select2.defaults,
    nextSearchTerm: (selectedObject, currentSearchTerm) ->
      currentSearchTerm
    escapeMarkup: (markup) ->
      markup
