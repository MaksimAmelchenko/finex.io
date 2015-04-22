@CashFlow.module 'ReferencesCategoriesApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'references_categories/list/layout'

    regions:
      panelRegion: '[name=panel-region]'
      listRegion: '[name=list-region]'

    collectionEvents:
      'sync:start': 'syncStart'
      'sync:stop': 'syncStop'

    syncStart: (entity) ->
      # triggered for deleting of model too, so just check
      if entity is @collection
        @addOpacityWrapper()

    syncStop: ->
      @addOpacityWrapper(false)

    onDestroy: ->
      @addOpacityWrapper(false)

  #-----------------------------------------------------------------------


  class List.Category extends App.Views.ItemView
    template: 'references_categories/list/_category'
    tagName: 'tr'

    modelEvents:
      'change': 'render'

    onRender: ->
#      @$el.data('ttBranch', true) if @model.isBranch
#      @$el.data('ttId', @model.id)
#      @$el.data('ttParentId', @model.get('parent')) if @model.get('parent')
      @$el.attr('data-tt-branch', 'true') if @model.isBranch
      @$el.attr('data-tt-id', @model.id)
      @$el.attr('data-tt-parent-id', @model.get('parent')) if @model.get('parent')

    events:
      'click': (e) ->
        e.stopPropagation()
        @model.toggleChoose()


  class List.Categories extends App.Views.ItemView
    template: 'references_categories/list/_categories'
    className: 'container-fluid'

    collectionEvents:
      'reset': 'render'

    ui:
      table: 'table'
      tbody: 'tbody'

    events:
      'click tbody > tr': (e) ->
        e.stopPropagation()
        App.entities.categories.get($(e.currentTarget).data('ttId')).toggleChoose()
      'click a[name=name]': (e) ->
        e.stopPropagation()
        @collection.get($(e.currentTarget).closest('tr').data('ttId')).choose()
        App.request 'category:edit', @collection.getFirstChosen()
        false
#      'click span.indenter > a': (e)->
#        e.stopPropagation()



    initialize: ->
      @listenTo @collection, 'change:chosen change:name change:note change:isEnabled', (model, value, options) =>
        tr = @$("tr[data-tt-id=#{model.id}]")
        $('[name=name]', tr).text(model.get('name'))
        $('[name=isEnabled] > i', tr).toggleClass('fa-check', model.get('isEnabled'))
        $('[name=note]', tr).text(model.get('note'))
        tr.toggleClass 'info', model.isChosen()

      @listenTo @collection, 'change:parent add', (model, value, options) =>
        model.choose()
        @render()

      @listenTo @collection, 'remove', (model, value, options) =>
        @ui.table.treetable('removeNode', model.id)


    renderRows: (parent = null) ->
      items = _.filter @collection.models, (model) ->
        return model.get('parent') is parent and not model.get('isSystem')


      _.each items, (item) =>
        item.isBranch = false
        $.each @collection.models, (i, model) ->
          if model.get('parent') is item.id and not model.get('isSystem')
            item.isBranch = true
            return false

      #      console.time('2')
      #      _.each items, (item) =>
      #        item.isBranch = (_.filter @collection.models, (model) ->
      #          return model.get('parent') is item.id and not model.get('isSystem')).length > 0
      #      console.timeEnd('2')

      #      console.time('2.3')
      #      _.each items, (item) =>
      #        item.isBranch = @collection.models.some (model) ->
      #          model.get('parent') is item.id and not model.get('isSystem')
      #      console.timeEnd('2.3')


      result = ''
      _.each items, (item) ->
        trClass = (if item.isChosen() then ' info' else '')

        result = result + """
          <tr #{if trClass isnt '' then 'class="' + trClass + '"' else ''}
              #{if item.isBranch then 'data-tt-branch="true"' else ''} data-tt-id="#{item.id}"
              #{if parent then 'data-tt-parent-id="' + parent + '"' else ''} >
            <td>
              <a href="#" name="name">
                #{item.get('name')}
              </a>
            </td>
            <td style="text-align: center;">
              <div name="isEnabled">
                <i class="fa #{if item.get('isEnabled') then 'fa-check' else '' }"></i>
              </div>
            </td>
            <td>
              <span name="note">#{item.get('note')}</span>
            </td>
          </tr>
          """
      result

    # TODO разобраться, почему не работает cursor: 'move'
    setDroppable: ->
      table = @ui.table
      $('a[name=name]', @ui.tbody).not('.ui-draggable').draggable
        helper: 'clone'
        cursor: 'move'
#        axis: 'y'
        opacity: .75
        refreshPositions: true
        revert: 'invalid'
        revertDuration: 300
        scroll: true
        start: (event, ui) =>
          $(this).css('cursor', 'move')
      .disableSelection()


      $('tr', @ui.tbody).not('.ui-droppable').droppable
        accept: 'a[name=name]'
#        accept: (el, a, b, c) ->
#          if el.is('span[name=name]') and not $.contains(el, this) then true else false
        drop: (e, ui) ->
          droppedEl = ui.draggable.parents('tr')
          table.treetable('move', droppedEl.data('ttId'), $(this).data('ttId'))
        hoverClass: 'accept'
        over: (e, ui) ->
          droppedEl = ui.draggable.parents('tr')
          if this != droppedEl[0] && !$(this).is('.expanded')
            table.treetable('expandNode', $(this).data('ttId'))

    onRender: ->
      view = @
      table = @ui.table
      @ui.tbody.append @renderRows()

      table.treetable
        expandable: true
#        clickableNodeNames: true
        stringCollapse: ''
        stringExpand: ''
        onMove: (node, destination) ->
          App.entities.categories.get(node.id).save({parent: destination.id}, {silent: true})
        onNodeExpand: ->
          if not this.isRendered
            this.isRendered = true
            table.treetable('loadBranch', this, view.renderRows(this.id))
            view.setDroppable()
      @setDroppable()


      current = @collection.getFirstChosen()

      if current
        idParent = current.get('parent')
        parents = []
        while  not _.isNull(idParent)
          parents.push idParent
          idParent = @collection.get(idParent).get('parent')

        idCategory = parents.pop()
        while idCategory
          table.treetable('expandNode', idCategory)
          idCategory = parents.pop()

      null


    onBeforeShow: ->
      @$el.css
        'padding-top': '90px'

  class List.Panel extends App.Views.ItemView
    template: 'references_categories/list/_panel'
    className: 'container-fluid'

    ui:
      btnAdd: '.btn[name=btnAdd]'
      btnEdit: '.btn[name=btnEdit]'
      btnDel: '.btn[name=btnDel]'
      btnRefresh: '.btn[name=btnRefresh]'
      btnMove: '.btn[name=btnMove]'

    initialize: ->
      @listenTo @collection, 'collection:unchose:one', =>
        (@ui.btnEdit.add @ui.btnDel).amkDisable()

      @listenTo @collection, 'collection:chose:one', (model)=>
        (@ui.btnEdit.add @ui.btnDel).amkEnable()


    events:
      'click @ui.btnAdd': 'add'
      'click @ui.btnEdit': 'edit'
      'click @ui.btnDel': 'del'
      'click @ui.btnRefresh': 'refresh'
      'click @ui.btnMove': 'move'

    add: ->
      model = App.request 'category:new:entity'
      current = @collection.getFirstChosen()
      model.set('parent', current.id) if current
      App.request 'category:edit', model

    edit: ->
      App.request 'category:edit', @collection.getFirstChosen()

    move: ->
      current = @collection.getFirstChosen()
      App.request 'category:move',
        idCategoryFrom: current?.id || null

    del: ->
      model.destroy() for model in @collection.getChosen()

    refresh: ->
      App.request 'category:entities',
        force: true

    onRender: ->
      if @collection.getChosen().length is 0
        (@ui.btnEdit.add @ui.btnDel).amkDisable()
