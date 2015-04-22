do (Backbone) ->
  _.extend Backbone.Marionette.Application::,

    getServer: ->
      'http://dev.finex.io:3000/v1'

