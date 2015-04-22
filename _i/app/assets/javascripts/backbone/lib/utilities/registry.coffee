@CashFlow.module 'Utilities', (Utilities, App, Backbone, Marionette, $, _) ->
  API =
    register: (instance, id) ->
#      console.log '+', id
      App._registry ?= {}
      App._registry[id] = instance

    unregister: (instance, id) ->
      delete App._registry[id]

    resetRegistry: ->
      oldCount = @getRegistrySize()
      for key, controller of App._registry
        controller.region.empty()

      # coffeelint: disable=max_line_length
      msg = "There were #{oldCount} controllers in the registry, there are now #{@getRegistrySize()}"
      # coffeelint: enable=max_line_length
      if @getRegistrySize() > 0 then console.warn(msg, App._registry) else console.log(msg)

    getRegistrySize: ->
      _.size App._registry

  App.commands.setHandler 'register:instance', (instance, id) ->
    API.register instance, id if App.environment is 'development'

  App.commands.setHandler 'unregister:instance', (instance, id) ->
    API.unregister instance, id if  App.environment is 'development'

  App.commands.setHandler 'reset:registry', ->
    API.resetRegistry()
