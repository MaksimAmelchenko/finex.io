@CashFlow.module 'Regions', (Regions, App, Backbone, Marionette, $, _) ->
  class Regions.Dialog extends Marionette.Region

    onBeforeShow: (view) ->
      dialogWrapper = $(JST['backbone/lib/components/regions/templates/dialog_wrapper']())
      view.$el.children().appendTo($('.modal-body', dialogWrapper))
      dialogWrapper.appendTo(view.$el)

    onShow: (view) ->
      @setupBindings view

      options = @getDefaultOptions _.result(view, 'dialog')

      @openDialog options

    setupBindings: (view) ->
      @listenTo view, 'dialog:close', =>
        @dialog.modal('hide')

    getDefaultOptions: (options = {}) ->
      _.defaults options,
        title: 'default title'
        backdrop: 'static'
        keyboard: false
        show: false

    openDialog: (options) ->
      @dialog = $('.modal', @$el)
      @dialog.modal(options)
      $('.modal-title', @dialog).html(@getTitle(options))

      $('.modal-dialog', @dialog)
      .draggable {
        handle: $('.modal-header', @dialog)
      }


      ## when modal fires the hidden.bs.modal event we want to close this region
      ## which will properly close our view and unbind all events
      @dialog.on 'hidden.bs.modal', =>
        @empty()

      @dialog.on 'shown.bs.modal', ->
        # Делаем правильный стек для модальных окон, что бы новое окно зетемняло предыдущее
        $dialog = $(@)
        count = $('div.modal.in').size()
        $dialog.css('z-index', 1050 + count * 2)
        $dialog.data('bs.modal').$backdrop.css('z-index', 1050 + count * 2 - 1)
        # По-умолчанию z-index=0 для .modal-dialog.
        # Это ломает расчет z-index для bootstrap-datepicker.
        # Поэтому выставляем z-index как у всего диалогового окна
        # https://github.com/twbs/bootstrap/issues/11139
        $('.modal-dialog', $dialog).css('z-index', $dialog.css('z-index'))

      @dialog.modal('show')

    getTitle: (options) ->
      _.result options, 'title'

    onEmpty: ->
      ## make sure to remove any listeners on the dialog here
      @dialog.off 'hidden.bs.modal'
      @dialog.off 'shown.bs.modal'

      @stopListening()
      @$el.remove()

  App.reqres.setHandler 'dialog:region', ->
    regionName = _.uniqueId('dialog-region-')

    $('body').append("<div id='#{regionName}'></div>")

    App._regionManager.addRegion regionName, {
      selector: '#' + regionName,
      regionClass: App.Regions.Dialog
    }


