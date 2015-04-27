do (Backbone) ->
  _.extend Backbone.Marionette.Application::,

    getServer: ->
      '{server}/v1'

