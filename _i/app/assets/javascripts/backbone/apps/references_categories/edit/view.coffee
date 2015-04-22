@CashFlow.module 'ReferencesCategoriesApp.Edit', (Edit, App, Backbone, Marionette, $, _) ->
  class Edit.Category extends App.Views.Layout
    template: 'references_categories/edit/layout'

    ui:
      name: '[name=name]'
      isEnabled: '[name=isEnabled]'
      parent: '[name=parent]'
      categoryPrototype: '[name=categoryPrototype]'
      note: '[name=note]'
      form: 'form'

    form:
      focusFirstInput: true

    events:
      'click .btn[name=btnSave]': 'save'
      'click .btn[name=btnCancel]': 'cancel'

    dialog: ->
      title: @getTitle()
      keyboard: false
      backdrop: 'static'

#    modelEvents:
#      'change': 'render'

    initialize: (options = {}) ->
      @config = options.config

    getTitle: ->
      "Категория &gt; #{if @model.isNew() then 'Добавление' else 'Редактирование'}"

    serialize: ->
      name: @ui.name.val()
      parent: @ui.parent.select2('data')?.id || null
      idCategoryPrototype: @ui.categoryPrototype.select2('data')?.id || null
      isEnabled: @ui.isEnabled.prop('checked')
      note: @ui.note.val()

    getPatch: ->
      compareJSON @model.toJSON(), @serialize()

    save: (e) ->
      e.preventDefault()
      return if not @ui.form.valid()

      if @model.isNew()
        @model.save @serialize(),
          success: (model, resp, options) =>
            @trigger 'form:after:save', @model

      else
        patch = @getPatch()

        if !_.isEmpty patch
          @model.save patch,
            patch: true
            success: (model, resp, options) =>
              @trigger 'form:after:save', @model
        else
          @trigger 'form:after:save', @model


    cancel: ->
      @trigger 'form:cancel'

    onRender: ->
      @ui.name.val @model.get('name')

      items = App.request 'category:filtered:entities',
        isSystem: false
        isEnabled: true
        without: @model.id
        idCategory: @model.get('parent')

      @ui.parent.select2
        allowClear: true
        minimumInputLength: if items.length > 300 then 2 else 0
        placeholder: 'Корень'
        data: items.map (category) ->
          id: category.id
          text: category.fullPath()
        matcher: (term, text, opt) ->
          App.Entities.categoryMatcher term, text, opt

      @ui.parent.select2('val', @model.get('parent'))

      @ui.categoryPrototype.select2
        allowClear: true
        placeholder: 'Нет'
        data: App.entities.categoryPrototypes.models.map (categoryPrototype) ->
          id: categoryPrototype.id
          text: categoryPrototype.fullPath()
        matcher: (term, text, opt) ->
          App.Entities.categoryMatcher term, text, opt

      @ui.categoryPrototype.select2('val', @model.get('idCategoryPrototype'))

      items = App.request 'category:filtered:entities',
        isSystem: false
        isEnabled: true
        without: @model.id
      #        idCategory: @model.get('prototype')

      #      @ui.prototype.select2
      #        allowClear: true
      #        placeholder: 'Нет'
      #        minimumInputLength: if items.length > 300 then 2 else 0
      #        data: items.map (category) ->
      #          id: category.id
      #          text: category.fullPath()
      ##        matcher: (term, text, opt) ->
      ##          text.toUpperCase().indexOf(term.toUpperCase())>=0  or opt.attr("alt").toUpperCase().indexOf(term.toUpperCase())>=0

      #      @ui.prototype.select2('val', @model.get('prototype'))

      @ui.isEnabled.prop('checked', @model.get('isEnabled'))
      @ui.note.val @model.get('note')

      @ui.form.validate
        rules:
          name:
            maxlength: 100
            required: true
        messages:
          name:
            maxlength: 'Пожалуйста, введите не более 100 символов.'
            required: 'Пожалуйста, введите название категории'

      @ui.form.submit (e) ->
        e.preventDefault()

    onDestroy: ->
      @ui.parent.select2 'destroy'
#      @ui.prototype.select2 'destroy'
