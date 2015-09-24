@CashFlow.module 'ReferencesCategoriesApp.Move', (Move, App, Backbone, Marionette, $, _) ->
  class Move.Layout extends App.Views.Layout
    template: 'references_categories/move/layout'

    ui:
      categoryFrom: '[name=categoryFrom]'
      categoryTo: '[name=categoryTo]'
      isRecursive: '[name=isRecursive]'
      form: 'form'

    form:
      focusFirstInput: true

    events:
      'click .btn[name=btnMove]': 'move'
      'click .btn[name=btnCancel]': 'cancel'

    templateHelpers: ->
      idCategory: @config.idCategoryFrom

    dialog: ->
      title: 'Перенос операций из одной категории в другую'
      keyboard: false
      backdrop: 'static'

    initialize: (options = {}) ->
      @config = options.config

    serialize: ->
      idCategoryFrom: @ui.categoryFrom.select2('data').id
      idCategoryTo: @ui.categoryTo.select2('data').id
      isRecursive: @ui.isRecursive.prop('checked')

    move: ->
      return if not @ui.form.valid()
      if @ui.categoryFrom.select2('data').id is @ui.categoryTo.select2('data').id and not @ui.isRecursive.prop('checked')
        showError """
          Нельзя переносить данные в тут же самую категорию без использования <br>
          опции "Переносить операции из подкатегорий"'
        """
        return

      _data = @serialize()
      @addOpacityWrapper()
      App.xhrRequest
        type: 'PUT'
        url: "categories/#{_data.idCategoryFrom}/move"
        data: JSON.stringify
          idCategoryTo: _data.idCategoryTo
          isRecursive: _data.isRecursive
        success: (res, textStatus, jqXHR) =>
          @addOpacityWrapper(false)
          showInfo "Перенесено: #{res.count} операций"
          @trigger 'form:after:save'
        error: =>
          @addOpacityWrapper(false)


    cancel: ->
      @trigger 'form:cancel'

    onRender: ->
      @ui.categoryFrom.select2
        minimumInputLength: if @ui.categoryFrom.children().size() > 300 then 2 else 0
        placeholder: 'Не выбрано'
      @ui.categoryFrom.select2('val', @config.idCategoryFrom)

      # for jQuery Validation Plugin
      @ui.categoryFrom.on 'change', ->
        $(@).trigger 'blur'

      @ui.categoryTo.select2
        placeholder: 'Не выбрано'
        minimumInputLength: if @ui.categoryTo.children().size() > 300 then 2 else 0

      # for jQuery Validation Plugin
      @ui.categoryTo.on 'change', ->
        $(@).trigger 'blur'

      @ui.isRecursive.prop('checked', false)

      @ui.form.validate
        rules:
          categoryFrom:
            required: true
          categoryTo:
            required: true
        messages:
          categoryFrom:
            required: 'Пожалуйста, выберите категорию, из которой переносить данные'
          categoryTo:
            required: 'Пожалуйста, выберите категорию, в которую переносить данные'

      @ui.form.submit (event) =>
        # prevent default browser behaviour
        event.preventDefault()
        @move()

    onDestroy: ->
      @ui.categoryFrom.select2 'destroy'
      @ui.categoryTo.select2 'destroy'
