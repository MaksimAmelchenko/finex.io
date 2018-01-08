@CashFlow.module 'ReportsDistributionApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Layout extends App.Views.Layout
    template: 'reports_distribution/show/layout'

    regions:
      panelRegion: '[name=panel-region]'
      dataRegion: '[name=data-region]'

    modelEvents:
      'sync:start': 'syncStart'
      'sync:stop': 'syncStop'

    syncStart: (entity) ->
      @addOpacityWrapper()

    syncStop: ->
      @addOpacityWrapper(false)

    onDestroy: ->
      @addOpacityWrapper(false)

  #-----------------------------------------------------------------------

  class Show.Panel extends App.Views.Layout
    template: 'reports_distribution/show/_panel'
    className: 'container-fluid'

    ui:
      form: 'form'
      valueType: '[name=valueType]'
      viewType: '[name=viewType]'
      btnToggleParams: '.btn[name=btnToggleParams]'
      btnRefresh: '.btn[name=btnRefresh]'

      params: '[name=params]'

      dBegin: '[name=dBegin]'
      dEnd: '[name=dEnd]'
      isUseReportPeriod: '[name=isUseReportPeriod]'
      money: '[name=money]'
      contractorsUsingType: '[name=contractorsUsingType]'
      contractors: '[name=contractors]'
      accountsUsingType: '[name=accountsUsingType]'
      accounts: '[name=accounts]'
      categoriesUsingType: '[name=categoriesUsingType]'
      categories: '[name=categories]'
      tagsUsingType: '[name=tagsUsingType]'
      tags: '[name=tags]'

#    modelEvents:
#      'sync': 'render'

    events:
      'click @ui.btnRefresh': 'refresh'
      'click @ui.btnToggleParams': 'toggleParams'
      'change @ui.contractors, @ui.accounts, @ui.categories, @ui.tags': 'resize'
      'change @ui.valueType': 'changeValueType'
      'change @ui.viewType': 'changeViewType'

    changeViewType: ->
      @model.viewType = parseInt(@ui.viewType.filter(':checked').val())
      @model.trigger 'refresh'

    changeValueType: ->
      @model.valueType = parseInt(@ui.valueType.select2 'val')
      @model.trigger 'refresh'

    resize: ->
      App.vent.trigger 'reports_distribution:panel:resize', @$el.height()

    refresh: ->
      return if not @ui.form.valid()
      @model.isShowParams = @ui.params.is(':visible')

      @model.valueType = parseInt(@ui.valueType.select2 'val')
      @model.viewType = parseInt(@ui.viewType.filter(':checked').val())

      dBegin = moment @ui.dBegin.datepicker('getDate')
      @model.params.dBegin = if dBegin.isValid() then dBegin.format('YYYY-MM-DD') else null
      dEnd = moment @ui.dEnd.datepicker('getDate')
      @model.params.dEnd = if dEnd.isValid() then dEnd.format('YYYY-MM-DD') else null

      if dBegin > dEnd
        showError 'Пожалуйста, укажите начальную дату меньше, чем конечную.'
        return

      @model.params.isUseReportPeriod = @ui.isUseReportPeriod.prop 'checked'
      @model.params.idMoney = parseInt @ui.money.select2('val')

      @model.params.contractorsUsingType = parseInt(@ui.contractorsUsingType.select2 'val')
      @model.params.contractors = _.map @ui.contractors.select2('val'), (item) ->
        parseInt item

      @model.params.accountsUsingType = parseInt(@ui.accountsUsingType.select2 'val')
      @model.params.accounts = _.map @ui.accounts.select2('val'), (item) ->
        parseInt item

      @model.params.categoriesUsingType = parseInt(@ui.categoriesUsingType.select2 'val')
      @model.params.categories = _.map @ui.categories.select2('val'), (item) ->
        parseInt item

      @model.params.tagsUsingType = parseInt(@ui.tagsUsingType.select2 'val')
      @model.params.tags = _.map @ui.tags.select2('val'), (item) ->
        parseInt item

      @model.fetch
        reset: true

    onDestroy: ->
      @ui.valueType.select2 'destroy'
      @ui.money.select2 'destroy'
      @ui.contractors.select2 'destroy'
      @ui.contractorsUsingType.select2 'destroy'
      @ui.accounts.select2 'destroy'
      @ui.accountsUsingType.select2 'destroy'
      @ui.categories.select2 'destroy'
      @ui.categoriesUsingType.select2 'destroy'
      @ui.tags.select2 'destroy'
      @ui.tagsUsingType.select2 'destroy'

    toggleParams: ->
      @ui.params.slideToggle
        duration: 50
        complete: =>
          @resize()

      $('.fa-caret-down, .fa-caret-right',
        @ui.btnToggleParams).toggleClass('fa-caret-down').toggleClass('fa-caret-right')

    onRender: ->
      @ui.valueType.select2()
      @ui.valueType.select2 'val', @model.valueType

      @ui.viewType.filter("[value=#{@model.viewType}]").prop('checked',
        true).parent().addClass('active')

      @ui.dBegin.datepicker()
      @ui.dBegin.datepicker('setDate',
        moment(@model.params.dBegin, 'YYYY-MM-DD').toDate()) if @model.params.dBegin
      @ui.dEnd.datepicker()
      @ui.dEnd.datepicker('setDate',
        moment(@model.params.dEnd, 'YYYY-MM-DD').toDate()) if @model.params.dEnd
      @ui.isUseReportPeriod.prop 'checked', @model.params.isUseReportPeriod

      @ui.money.select2()
      @ui.money.select2('val', @model.params.idMoney)


      @ui.contractorsUsingType.select2()
      @ui.contractorsUsingType.select2 'val', @model.params.contractorsUsingType
      @ui.contractors.select2
        placeholder: 'Все'
      @ui.contractors.select2('val', @model.params.contractors)

      @ui.accountsUsingType.select2()
      @ui.accountsUsingType.select2 'val', @model.params.accountsUsingType
      @ui.accounts.select2
        placeholder: 'Все'
      @ui.accounts.select2('val', @model.params.accounts)

      @ui.categoriesUsingType.select2()
      @ui.categoriesUsingType.select2 'val', @model.params.categoriesUsingType
      @ui.categories.select2
        placeholder: 'Все'
        minimumInputLength: if @ui.categories.children().size() > 300 then 2 else 0
      @ui.categories.select2('val', @model.params.categories)

      @ui.tagsUsingType.select2()
      @ui.tagsUsingType.select2 'val', @model.params.tagsUsingType
      @ui.tags.select2
        placeholder: 'Все'

      @ui.tags.select2('val', @model.params.tags)

      @ui.btnToggleParams.trigger 'click' if @model.isShowParams

      @ui.form.validate
        rules:
          dBegin_:
            required: true
          dEnd_:
            required: true
        messages:
          dBegin_:
            required: 'Пожалуйста, укажите дату.',
          dEnd_:
            required: 'Пожалуйста, укажите дату.',

      @resize()

  #-----------------------------------------------------------------------
  class Show.Data extends App.Views.Layout
    template: 'reports_distribution/show/_data'

    modelEvents:
      'sync refresh': 'showData'

    regions:
      viewRegion: '[name=view-region]'

    showData: ->
      if @model.viewType is 1
        tableView = new Show.Table
          model: @model
        @viewRegion.show tableView
#          forceShow: true
      else
        graphView = new Show.Graph
          model: @model
        @viewRegion.show graphView
#          forceShow: true

    onShow: ->
      @showData()

    initialize: ->
      App.vent.on 'reports_distribution:panel:resize', (height) =>
        @$el.css
          'padding-top': (height + 5) + 'px'

    onBeforeShow: ->
      @$el.css
        'padding-top': App.request('reports_distribution:panel:height') + 5 + 'px'


  class Show.Table extends App.Views.ItemView
    template: 'reports_distribution/show/_table'
    className: 'container-fluid'

#    modelEvents:
#      'sync refresh': 'render'

    ui:
      table: 'table'

#    events:
#      'click @ui.tickbox, .date': (e) ->
#        e.stopPropagation()
#        @model.toggleChoose()

    renderRows: (parent) ->
      if parent is null
        _items = @model.get 'items'
      else
        _items = @model.cache[parent].items

      _items = _.filter _items, (item) =>
        Show.getValue(item.sum, @model.valueType) > 0

      items = _.sortBy _items, (item) =>
        -Show.getValue(item.sum, @model.valueType)
      #        if item.idCategory
      #          CashFlow.entities.categories.get(item.idCategory).get('name')
      #        else
      #          null

      result = ''
      _.each items, (item) =>
        result = result + """
          <tr #{if item.items.length > 0 then 'data-tt-branch="true"' else ''}
              data-tt-id="#{if item.idCategory then item.idCategory else -parent}"
              #{if parent then 'data-tt-parent-id="' + parent + '"'} >
            <td style="white-space: nowrap">
              #{if item.idCategory then _.escape(CashFlow.entities.categories.get(item.idCategory).get('name')) else 'Другое'}
            </td>
            <td class="sum">
              #{s.numberFormat(Show.getValue(item.sum, @model.valueType), 0, '.', ' ')}
            </td>
          </tr>
          """
      result

    onRender: ->
      view = @
      table = @ui.table
      table.treetable
        expandable: true
        clickableNodeNames: true
        stringCollapse: ''
        stringExpand: ''
        onNodeExpand: ->
          if not this.isRendered
            table.treetable('loadBranch', this, view.renderRows(this.id))
            this.isRendered = true
#        onNodeCollapse: ->
#          table.treetable('unloadBranch', this)

    templateHelpers: ->
      _.extend super,
        getValue: (sum) =>
          Show.getValue(sum, @model.valueType)
        renderRoot: =>
          @renderRows null

  class Show.Graph extends App.Views.ItemView
    template: 'reports_distribution/show/_graph'
    className: 'container-fluid'

    ui:
      graph: '[name=graph]'
      tooltip: '[name=tooltip]'

    renderGraph: ->
      @data =
        items: @model.get 'items'

      @ui.graph.empty()
      return if @data.items.length is 0

      @margin =
        top: 20
        right: 20
        bottom: 20
        left: 20

      l = Math.min(@ui.graph.width(), 600)
      @width = l - @margin.left - @margin.right
      @height = l - @margin.top - @margin.bottom
      @radius = Math.min(@width, @height) / 2

      @x = d3.scale.linear().range([0, 2 * Math.PI])
      @y = d3.scale.sqrt().range([0, @radius])

      color = d3.scale.category20()

      @svg = d3.select(@ui.graph[0]).append("svg")
      .attr("width", @width + @margin.left + @margin.right)
      .attr("height", @height + @margin.top + @margin.bottom)
      .append("g")
      .attr("transform",
        "translate(" + (@margin.left + @radius) + "," + (@margin.top + @radius ) + ")")

      partition = d3.layout.partition()
      .children (d) ->
        if d.items.length > 0 then d.items else null
      .value (d) =>
        Show.getValue(d.sum, @model.valueType)

      @arc = d3.svg.arc()
      .startAngle (d) =>
        Math.max(0, Math.min(2 * Math.PI, @x(d.x)))
      .endAngle (d) =>
        Math.max(0, Math.min(2 * Math.PI, @x(d.x + d.dx)))
      .innerRadius (d) =>
        Math.max(0, @y(d.y))
      .outerRadius (d) =>
        Math.max(0, @y(d.y + d.dy))


      body = $('html')[0]
      path = @svg.selectAll("path")
      .data(partition.nodes(@data))
      .enter().append("path")
      .attr("d", @arc)
      .style("fill", (d) ->
#        debugger
#        color((if d.children then d else d.parent).idCategory))
        color(d.idCategory))
      .on("click", (d) =>
        path.transition()
        .duration(750)
        .attrTween("d", @arcTween(d))
      )
      .on 'mousemove', (d, i) =>
        @ui.tooltip
        .css {
          left: d3.event.clientX + 10
          top: d3.event.clientY
        }
      .on 'mouseover', (d, i) =>
        @ui.tooltip.html(
          (if d.idCategory
            _.escape(App.entities.categories.get(d.idCategory).get('name'))
          else
            (if d.parent then 'Другое' else 'Всего')) + ": " + s.numberFormat(d.value, 0, '.', ' ')
        )
        .css {
          left: d3.event.clientX + 10
          top: d3.event.clientY
        }
        .show()
      .on 'mouseout', =>
        @ui.tooltip.hide()

      d3.select(self.frameElement).style("height", @height + "px")

    # Interpolate the scales!
    arcTween: (d) ->
      xd = d3.interpolate(@x.domain(), [d.x, d.x + d.dx])
      yd = d3.interpolate(@y.domain(), [d.y, 1])
      yr = d3.interpolate(@y.range(), [(if d.y then 40 else 0), @radius])

      x = @x
      y = @y
      arc = @arc

      (d, i) ->
        if i then (t) ->
          arc (d)
        else (t) ->
          x.domain(xd(t))
          y.domain(yd(t)).range(yr(t))
          arc(d)


    onShow: ->
      @renderGraph()
