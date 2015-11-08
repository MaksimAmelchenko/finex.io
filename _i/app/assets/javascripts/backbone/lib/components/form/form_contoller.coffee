@CashFlow.module 'Components.Form', (Form, App, Backbone, Marionette, $, _) ->
  class Form.FormController extends App.Controllers.Application

    defaults: ->
      focusFirstInput: true
      syncing: true
      proxy: false


    initialize: (options = {}) ->
      {@contentView}  = options
      @model = @getModel options

      config = @getConfig options

      @formLayout = @getFormLayout config
      @setMainView @formLayout

      @parseProxys config.proxy if config.proxy
      @createListeners config

    createListeners: (config) ->
      @listenTo @formLayout, 'show', @formContentRegion

      @listenTo @contentView, 'all', (event, model, options) ->
        @trigger event, model, options if _.startsWith(event, 'form:')

#      @listenTo @contentView, 'form:after:save', (model)->
#        @trigger 'form:after:save', model
#
#      @listenTo @contentView, 'form:cancel', ->
#        @trigger 'form:cancel'

#      @listenTo @contentView, 'form:close', ->
#        @trigger 'form:close'

#      @listenTo @formLayout, "form:submit", => @formSubmit(config)
#      @listenTo @formLayout, "form:cancel", => @formCancel(config)

    getConfig: (options) ->
      form = _.result @contentView, 'form'

      config = @mergeDefaultsInto(form)

      _.extend config, _.omit(options, 'contentView', 'model', 'collection')

    getModel: (options) ->
      ## pull model off of contentView by default
      ## allow options.model to override
      ## or instantiate a new model if nothing is present
      model = options.model or @contentView.model
      if options.model is false
        model = App.request 'new:model'
        @_saveModel = false
      model
#
#    getCollection: (options) ->
#      options.collection or @contentView.collection

    parseProxys: (proxys) ->
      for proxy in _.flatten([proxys])
        @formLayout[proxy] = _.result @contentView, proxy

#      formCancel: (config) ->
#        config.onFormCancel()
#        @trigger "form:cancel"

#      formSubmit: (config) ->
#        ## pull data off of form
#        data = Backbone.Syphon.serialize @formLayout
#
#        ## notify our controller instance in case things are listening to it
#        @trigger("form:submit", data)
#
#        @processModelSave(data, config) unless @_shouldNotProcessModelSave(config, data)

#      _shouldNotProcessModelSave: (config, data) ->
#        @_saveModel is false or config.onFormSubmit is false or config.onFormSubmit?(data) is false

#      processModelSave: (data, config) ->
#        @model.save data,
#          collection: @collection
#          callback: config.onFormSuccess

    formContentRegion: ->
      @show @contentView, region: @formLayout.formContentRegion
#        Backbone.Syphon.deserialize @formLayout, @model.toJSON()

    getFormLayout: (config) ->
      new Form.FormLayout
        config: config
        model: @model
  #          buttons: @getButtons config.buttons

  #      getButtons: (buttons = {}) ->
  #        App.request("form:button:entities", buttons, @contentView.model) unless buttons is false

  App.reqres.setHandler 'form:component', (contentView, options = {}) ->
    throw new Error 'Form Component requires a contentView to be passed in' if not contentView

    options.contentView = contentView
    new Form.FormController options
