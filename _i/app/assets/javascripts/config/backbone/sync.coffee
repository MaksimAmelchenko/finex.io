do (Backbone) ->
  _sync = Backbone.sync

  Backbone.sync = (method, entity, options = {}) ->
    _.defaults options,
      beforeSend: _.bind(methods.beforeSend, entity)
      complete: _.bind(methods.complete, entity)
    #      crossDomain: true

    sync = _sync(method, entity, options)
    #    if entity._fetch
    #      entity._fetch.abort()

    if !entity._fetch and method is 'read'
      entity._fetch = sync

  methods =
    beforeSend: ->
      @trigger 'sync:start', @

    complete: ->
      @trigger 'sync:stop', @
      delete @._fetch

