do ($) ->
  $.fn.jarvismenu = (options) ->
    defaults =
      accordion: 'true'
      speed: 200
      closedSign: '[+]'
      openedSign: '[-]'


    # Extend our default options with those provided.
    opts = $.extend(defaults, options)
    #Assign current element to variable, in this case is UL element
    $this = $(this)

    # add a mark [+] to a multilevel menu
    $this.find("li").each ->
      if ($(this).find("ul").size() isnt 0)
        # add the multilevel sign next to the link
        $(this).find("a:first").append("<b class='collapse-sign'>" + opts.closedSign + "</b>")

        #avoid jumping to the top of the page when the href is an #
        if ($(this).find("a:first").attr('href') == "#")
          $(this).find("a:first").click ->
            false


    # open active level
    $this.find("li.active").each ->
      $(this).parents("ul").slideDown(opts.speed)
      $(this).parents("ul").parent("li").find("b:first").html(opts.openedSign)
      $(this).parents("ul").parent("li").addClass("open")


    $this.find("li a").click ->
      if ($(this).parent().find("ul").size() isnt 0)

        if (opts.accordion)
          # Do nothing when the list is open
          if (!$(this).parent().find("ul").is(':visible'))
            parents = $(this).parent().parents("ul")
            visible = $this.find("ul:visible")
            visible.each (visibleIndex) ->
              close = true
              parents.each (parentIndex) ->
                if (parents[parentIndex] == visible[visibleIndex])
                  close = false
                  false
              if (close)
                if ($(this).parent().find("ul") != visible[visibleIndex])
                  $(visible[visibleIndex]).slideUp opts.speed, ->
                    $(this).parent("li").find("b:first").html(opts.closedSign)
                    $(this).parent("li").removeClass("open")


        # coffeelint: disable=max_line_length
        if ($(this).parent().find("ul:first").is(":visible") && !$(this).parent().find("ul:first").hasClass("active"))
          # coffeelint: enable=max_line_length

          $(this).parent().find("ul:first").slideUp opts.speed, ->
            $(this).parent("li").removeClass("open")
            $(this).parent("li").find("b:first").delay(opts.speed).html(opts.closedSign)


        else
          $(this).parent().find("ul:first").slideDown opts.speed, ->
            $(this).parent("li").addClass("open")
            $(this).parent("li").find("b:first").delay(opts.speed).html(opts.openedSign)

#      else
#        $this.find('li.active').removeClass("active")
#        $(this).parent("li").addClass("active")


  window.showError = (message) ->
    $('.top-right')
    .notify(
      fadeOut: {enabled: true, delay: 5000}
      message: {html: message}
      type: 'danger'
    )
    .show()


  window.showInfo = (message, sticky = false) ->
    if sticky
      fadeOut = {enabled: false}
    else
      fadeOut = {enabled: true, delay: 5000}

    $('.top-right')
    .notify(
      fadeOut: fadeOut
      message: {html: message}
      type: 'info'
    )
    .show()
