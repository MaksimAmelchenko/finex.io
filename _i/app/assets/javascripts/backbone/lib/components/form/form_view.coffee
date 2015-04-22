@CashFlow.module 'Components.Form', (Form, App, Backbone, Marionette, $, _) ->
  class Form.FormLayout extends  App.Views.Layout
    template: 'form/form'

#    attributes: ->
#      'data-type': @getFormDataType()

    regions:
      formContentRegion: '[role=form-content-region]'

#    triggers:
#      'submit': 'form:submit'
#      'click .btn-default': 'form:cancel'

    modelEvents:
      'sync:start': 'syncStart'
      'sync:stop': 'syncStop'

    initialize: ->
      @setInstancePropertiesFor 'config'

#    serializeData: ->
#      footer: @config.footer

    onShow: ->
      _.defer =>
        @focusFirstInput() if @config.focusFirstInput

    focusFirstInput: ->
#      @$('input:visible:enabled:first').focus()
      @$(':text:visible:enabled:first').focus()

#    getFormDataType: ->
#      if @model.isNew() then 'new' else 'edit'

    syncStart: (model) ->
#      debugger
#      @formContentRegion.$el.addOpacityWrapper() if @config.syncing
      @addOpacityWrapper() if @config.syncing

    syncStop: (model) ->
#      @formContentRegion.$el.addOpacityWrapper(false) if @config.syncing
      @addOpacityWrapper(false) if @config.syncing

    onDestroy: ->
      @addOpacityWrapper(false) if @config.syncing
