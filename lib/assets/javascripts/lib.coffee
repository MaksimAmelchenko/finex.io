do ($) ->
  $.fn.amkEnable = ->
    #    _.defer =>
    @removeAttr("disabled").removeClass("disabled")

  $.fn.isAmkEnable = ->
    !@hasClass("disabled")

  $.fn.amkDisable = ->
    #    _.defer =>
    @attr("disabled", "disabled").addClass("disabled")

  $.fn.toggleWrapper = (obj = {}, cid, init) ->
    methods =
      getWrapperByCid: (cid) ->
        $("[data-wrapper='#{cid}']")

      isTransparent: (bg) ->
        /transparent|rgba/.test bg

      setBackgroundColor: (bg) ->
        if @isTransparent(bg) then "white" else bg

    _.defaults obj,
      className: ""
      backgroundColor: methods.setBackgroundColor @css("backgroundColor")
      zIndex: if @css("zIndex") is "auto" or 0 then 5000 else (Number) @css("zIndex")

#    $offset = @offset()
    $offset = @position()
    $width = @outerWidth(false)
    $height = @outerHeight(false)

    if init
      ## don't add another wrapper if one is already present
      return if methods.getWrapperByCid(cid).length

      ## add the wrapper
      $("<div>")
#      .appendTo("body")
      .appendTo(@)

      .addClass(obj.className)
      .attr("data-wrapper", cid)
      .css {
        width: $width
        height: $height
        top: $offset.top
        left: $offset.left
        position: "absolute"
        zIndex: obj.zIndex + 1
        backgroundColor: obj.backgroundColor
      }
    else
      ## remove the wrapper
      methods.getWrapperByCid(cid).remove()


  window.numToJSON = (value) ->
    if (value is null or value is undefined or value is '')
      null
    else
      if (typeof value is 'string') then Number(value.replace(',', '.')) else Number(value)

  window.strToJSON = (value) ->
    '"' + value + '"'

  window.compareJSON = (obj1, obj2, filter) ->
    result = {}
    for key, value of _.omit(obj2, filter)
      if obj2.hasOwnProperty key
        if _.isArray(obj2[key]) and !obj2[key].equals(obj1[key])
          result[key] = obj2[key]
        else
          if !_.isObject(obj2[key]) and obj2[key] isnt obj1[key]
            result[key] = obj2[key]
    result


  # attach the .equals method to Array's prototype to call it on any array
  Array.prototype.equals = (array) ->
    # if the other array is a falsy value, return
    if !array
      return false

    # compare lengths - can save a lot of time
    if (@length isnt array.length)
      return false


    for element, i in @
      # Check if we have nested arrays
      if (element instanceof Array && array[i] instanceof Array)
        # recurse into the nested arrays
        if not element.equals(array[i])
          return false
      else
        if element isnt array[i]
          # Warning - two different object instances will never be equal: {x:20} != {x:20}
          return false
    true

  window.getParam = (name) ->
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
    regexS = "[\\?&]" + name + "=([^&#]*)"
    regex = new RegExp(regexS)
    results = regex.exec(window.location.href)
    if not results
      ''
    else
      return results[1]

  window.round = (value, decimals) ->
    Number(Math.round(value + 'e' + decimals) + 'e-' + decimals)
