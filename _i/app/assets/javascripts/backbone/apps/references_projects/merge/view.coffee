@CashFlow.module 'ReferencesProjectsApp.Merge', (Merge, App, Backbone, Marionette, $, _) ->
  class Merge.Layout extends App.Views.Layout
    template: 'references_projects/merge/layout'

    ui:
      targetProject: '[name=targetProject]'
      projects: '[name=projects]'
      isAgree: '[name=isAgree]'
      btnMerge: '.btn[name=btnMerge]'
      form: 'form'

    form:
      focusFirstInput: true

    events:
      'click @ui.btnMerge': 'merge'
      'click .btn[name=btnCancel]': 'cancel'
      'change @ui.isAgree': 'changeIsAgree'

    dialog: ->
      title: 'Объединение проектов'
      keyboard: false
      backdrop: 'static'

    initialize: (options = {}) ->
      @config = options.config

    merge: ->
      return if not @ui.form.valid()

      @addOpacityWrapper()
      App.xhrRequest
        type: 'POST'
        url: "projects/#{@ui.targetProject.select2('val')}/merge"
        data: JSON.stringify
          projects: _.map @ui.projects.select2('val'), (item) ->
            parseInt item
        success: (res, textStatus, jqXHR) =>
          @addOpacityWrapper(false)
          showInfo JST['backbone/apps/references_projects/merge/templates/_result_message'](res), true
          App.request 'project:entities',
            force: true

          App.entities.accounts.reset res.accounts if res.accounts
          App.entities.contractors.reset res.contractors if res.contractors
          App.entities.categories.reset res.categories if res.categories
          App.entities.units.reset res.units if res.units
          App.entities.tags.reset res.tags if res.tags

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

    changeIsAgree: ->
      if @ui.isAgree.prop('checked')
        @ui.btnMerge.amkEnable()
      else
        @ui.btnMerge.amkDisable()

    onRender: ->
      @ui.btnMerge.amkDisable()

      @ui.targetProject.select2
        placeholder: 'Не выбрано'
      @ui.targetProject.select2('val', @config.idTargetProject)

      # for jQuery Validation Plugin
      @ui.targetProject.on 'change', ->
        $(@).trigger 'blur'

      @ui.projects.select2
        placeholder: 'Не выбрано'
      # for jQuery Validation Plugin
      @ui.projects.on 'change', ->
        $(@).trigger 'blur'

      @ui.form.validate
        rules:
          targetProject:
            required: true
          projects:
            required: true
        messages:
          targetProject:
            required: 'Пожалуйста, выберите целевой проект.'
          projects:
            required: 'Пожалуйста, выберите хотя бы один объединяемый проект.'

      @ui.form.submit (event) =>
        # prevent default browser behaviour
        event.preventDefault()
        @merge()

    onDestroy: ->
      @ui.targetProject.select2 'destroy'
      @ui.projects.select2 'destroy'
