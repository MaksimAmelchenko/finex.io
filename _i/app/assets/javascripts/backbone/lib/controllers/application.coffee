@CashFlow.module 'Controllers', (Controllers, App, Backbone, Marionette, $, _) ->
  class Controllers.Application extends Marionette.Controller

    constructor: (options = {}) ->
      @_instance_id = _.uniqueId('controller')
      App.execute 'register:instance', @, @_instance_id
      @region = options.region or App.request 'default:region'
      super options

    destroy: ->
#      console.log 'destroy', @
      App.execute 'unregister:instance', @, @_instance_id
      super

    show: (view, options = {}) ->
      _.defaults options,
        loading: false,
        region: @region
      ## allow us to pass in a controller instance instead of a view
      ## if controller instance, set view to the mainView of the controller
      view = if view.getMainView then view.getMainView() else view

      # coffeelint: disable=max_line_length
      throw new Error("getMainView() did not return a view instance or #{view?.constructor?.name} is not a view instance") if not view
      # coffeelint: enable=max_line_length

      @setMainView view
      @_manageView view, options

    getMainView: ->
      @_mainView

    setMainView: (view) ->
      ## the first view we show is always going to become the mainView of our
      ## controller (whether its a layout or another view type).  So if this
      ## *is* a layout, when we show other regions inside of that layout, we
      ## check for the existance of a mainView first, so our controller is only
      ## closed down when the original mainView is closed.
      return if @_mainView
      @_mainView = view
      @listenTo view, 'destroy', @destroy

    _manageView: (view, options) ->
      if options.loading
        ## show the loading view
        App.execute 'show:loading', view, options
      else
        options.region.show view

    mergeDefaultsInto: (obj) ->
      obj = if _.isObject(obj) then obj else {}
      _.defaults obj, @_getDefaults()

    _getDefaults: ->
      _.clone _.result(@, "defaults")

#    onClose: ->
#      console.log 'close base controller', @

