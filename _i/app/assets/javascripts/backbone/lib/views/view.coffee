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
        App.Utilities.numberToMoney(value, idMoney)

      formatDate: (value, isShort = false) ->
        if value
          d = moment(value, 'YYYY-MM-DD')
          if isShort
            d.format('DD.MM.YY')
          else
            #            '<div> ' + s.titleize(d.format('DD<br> MMM')) + '</div>'
            d.format('DD.MM.YYYY')


