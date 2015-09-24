@CashFlow.module 'ReferencesProjectsApp.Copy', (Copy, App, Backbone, Marionette, $, _) ->
  class Copy.Layout extends App.Views.Layout
    template: 'references_projects/copy/layout'

    ui:
      projectFrom: '[name=projectFrom]'
      name: '[name=name]'
      form: 'form'

    form:
      focusFirstInput: true

    events:
      'click .btn[name=btnCopy]': 'copy'
      'click .btn[name=btnCancel]': 'cancel'

    dialog: ->
      title: 'Копирование проекта'
      keyboard: false
      backdrop: 'static'

    initialize: (options = {}) ->
      @config = options.config

    copy: ->
      return if not @ui.form.valid()

      @addOpacityWrapper()

      App.xhrRequest
        type: 'POST'
        url: "projects/#{@ui.projectFrom.select2('val')}/copy"
        data: JSON.stringify
          name: @ui.name.val()
        success: (res, textStatus, jqXHR) =>
          @addOpacityWrapper(false)
          App.entities.projects.add(new App.Entities.Project(res.project))
          showInfo 'Проект спопирован'
          @trigger 'form:after:save'
        error: =>
          @addOpacityWrapper(false)

      # Give ~20 sec for import. Default trickleSpeed = 800 ms, so trickleRate = 100% / (20000ms/800ms) * 2 = 8%
      # коэффициент 2 делаем потому, что trickleRate коректируется random()
      NProgress.configure
        trickle: true
        trickleRate: 0.08


    cancel: ->
      @trigger 'form:cancel'

    onRender: ->
      @ui.projectFrom.select2
        placeholder: 'Не выбрано'
      @ui.projectFrom.select2('val', @config.idProjectFrom)

      # for jQuery Validation Plugin
      @ui.projectFrom.on 'change', ->
        $(@).trigger 'blur'

      @ui.form.validate
        rules:
          projectFrom:
            required: true
          name:
            required: true
            maxlength: 30
        messages:
          projectFrom:
            required: 'Пожалуйста, выберите копируемый проект.'
          name:
            maxlength: 'Пожалуйста, введите не более 30 символов.'
            required: 'Пожалуйста, введите название проекта.'

      @ui.form.submit (event) =>
        # prevent default browser behaviour
        event.preventDefault()
        @copy()

    onDestroy: ->
      @ui.projectFrom.select2 'destroy'
