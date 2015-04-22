@CashFlow.module 'Utilities', (Utilities, App, Backbone, Marionette, $, _) ->
  _.extend App,

    xhrPool: []

    xhrRequest: (options = {}) ->
      _.defaults options,
        type: 'GET'
        success: $.noop
        error: $.noop

      $.ajax
        url: App.getServer() + '/' + options.url
        crossDomain: true
        type: options.type
        contentType: 'application/json'
        dataType: 'json'
        data: options.data
        success: options.success
        error: options.error

    xhrAbortAll: ->
      $.each App.xhrPool, (i, jqXHR) ->
        jqXHR.abort()

  Utilities.on 'start', ->
    $(document).ajaxSend (event, jqXHR, options) ->
      App.xhrPool.push(jqXHR)

    $(document).ajaxComplete (event, jqXHR, options) ->
      App.xhrPool = $.grep App.xhrPool, (x) ->
        x != jqXHR

