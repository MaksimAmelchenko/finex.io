@CashFlow.module "Views", (View, App, Backbone, Marionette, $, _) ->
  _remove = Marionette.View::remove

  _.extend Marionette.View::,
    addOpacityWrapper: (init = true, options = {}) ->
      _.defaults options,
        className: 'opacity'

      if @formContentRegion
        @formContentRegion.$el.toggleWrapper options, @cid, init
      else
        @$el.toggleWrapper options, @cid, init

    setInstancePropertiesFor: (args...) ->
      for key, val of _.pick(@options, args...)
        @[key] = val

    remove: (args...) ->
#      console.log 'removing view', @
      fadeOutTime = 400

      if @model?.isDestroyed?()

        wrapper = @addOpacityWrapper true,
          backgroundColor: 'red'

        wrapper.fadeOut fadeOutTime, ->
          $(@).remove()

        @$el.fadeOut fadeOutTime, =>
          _remove.apply @, args
      else
        _remove.apply @, args


    templateHelpers: ->
      linkTo: (name, url, options = {}) ->
        _.defaults options,
          external: false

        url = '#' + url unless options.external

        "<a href='#{url}'>#{@escape(name)}</a>"

      numberToMoney: (value, idMoney) ->
        '<nobr>' + s.numberFormat(value, 2, '.', ' ') + '</nobr>'

      formatDate: (value) ->
        moment(value, 'YYYY-MM-DD').format('DD.MM.YYYY') if value


