@CashFlow.module 'Utilities', (Utilities, App, Backbone, Marionette, $, _) ->
  _.extend App ,

    navigate: (route, options = {}) ->
      Backbone.history.navigate route, options

    getCurrentRoute: ->
      frag = Backbone.history.fragment
      if _.isEmpty(frag) then null else frag

    startHistory: ->
      if Backbone.history
        Backbone.history.start()

