@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Model extends Backbone.Model
    constructor: ->
      @on 'destroy', =>
        @unchoose?()

      super


    destroy: (options = {}) ->
      _.defaults options,
        wait: true
        error: _.bind(@destroyError, @)
      #        success: _.bind(@destroySuccess, @)

      @set _destroy: true
      super options

    isDestroyed: ->
      @get '_destroy'

#    destroySuccess: (model, xhr, options) =>
#      debugger
#      model.unchoose?()

    destroyError: (model, xhr, options) =>
      @unset '_destroy'

#      console.log $.parseJSON(xhr.responseText)?.error.message
#      console.log $.parseJSON(xhr.responseText)?.error.devMessage

    # Для модели переопределяем toJSON - только указанные атрибуты сериализуются
#    toJSON: (options = {}) ->
#      if _.isEmpty(options)
#        super
#      else
#        _.pick(@attributes, options)

    fetch: (options) ->
      options = $.extend(options, {
        data: @data?()
      })
      super options

    save: (data, options = {}) ->
#      isNew = @isNew()
      _.defaults options,
        wait: true
      #        success: _.bind(@saveSuccess, @, isNew, options.collection, options.callback)
      #        success: _.bind(@saveSuccess, @)
      #        error: _.bind(@saveError, @)

      super data, options

  #    saveSuccess: (isNew, collection, callback) =>
  #      debugger
  #      if isNew
  #        collection.add @ if collection
  #        collection.trigger 'model:created', @ if collection
  #      else
  #        collection ?= @collection
  #        collection.trigger 'model:updated', @ if collection
  #        @trigger 'updated', @
  #
  #      callback?()

  #    saveError: (model, xhr, options) =>
  #      error = $.parseJSON(xhr.responseText)?.error
  #      showError(if error.message isnt '' then error.message else error.devMessage)

  API =
    newModel: (attrs) ->
      new Entities.Model attrs

  App.reqres.setHandler 'new:model', (attrs = {}) ->
    API.newModel attrs
