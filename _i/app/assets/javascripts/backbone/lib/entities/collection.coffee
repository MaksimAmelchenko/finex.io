@CashFlow.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Collection extends Backbone.Collection

    constructor: (options = {}) ->
#      @on 'all', (event, model) ->
#        console.log event
      @options = options
      _.defaults @options,
        limit: 50
        offset: 0

      @limit = @options.limit
      @offset = @options.offset
      @total = 0

      @on 'add', (model) ->
        model.unchoose?()
        @total = @total + 1

      @on 'remove', (model) ->
        model.unchoose?()
        @total = @total - 1 if @total > 0

      @on 'reset', (collection) ->
        collection.chooseNone?()
      super

    resetPagination: ->
      @limit = @options.limit
      @offset = @options.offset

    isFirstPage: ->
      @offset is 0

    isLastPage: ->
      @offset + @length is @total
#      @offset is Math.round(@length / @limit)

    firstPage: (cb) ->
      @offset = 0
      @fetch
        reset: true
        success: ->
          cb?()

    previousPage: (cb) ->
      @offset = Math.max @offset - @limit, 0
      @fetch
        reset: true
        success: ->
          cb?()

    nextPage: (cb) ->
      @offset = @offset + @limit
      @fetch
        reset: true
        success: ->
          cb?()

    lastPage: (cb) ->
      @offset = Math.round(@total / @limit) * @limit
      @fetch
        reset: true
        success: ->
          cb?()

    fetch: (options) ->
      options = $.extend(options, {
        url: App.getServer() + '/' + @url
        data: @data?()
      })

      super options

