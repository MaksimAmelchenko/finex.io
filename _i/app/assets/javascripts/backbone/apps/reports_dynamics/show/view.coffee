@CashFlow.module 'ReportsDynamicsApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Layout extends App.Views.Layout
    template: 'reports_dynamics/show/layout'

    regions:
      panelRegion: '[name=panel-region]'
      dataRegion: '[name=data-region]'

    modelEvents:
      'sync:start': 'syncStart'
      'sync:stop': 'syncStop'

    syncStart: (entity) ->
      # triggered for deleting of model too, so just check
#      if entity is @collection
      @addOpacityWrapper()

    syncStop: ->
      @addOpacityWrapper(false)

    onDestroy: ->
      @addOpacityWrapper(false)

  #-----------------------------------------------------------------------

  class Show.Panel extends App.Views.Layout
    template: 'reports_dynamics/show/_panel'
    className: 'container-fluid'

    ui:
      form: 'form'
      valueType: '[name=valueType]'
      btnToggleParams: '.btn[name=btnToggleParams]'
      btnRefresh: '.btn[name=btnRefresh]'
      viewType: '[name=viewType]'

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
      isUsePlan: '[name=isUsePlan]'

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
      App.vent.trigger 'reports_dynamics:panel:resize', @$el.height()

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
        showError 'Пожалуйста, укажите начальную дату меньше, чем конечную'
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

      @model.params.isUsePlan = @ui.isUsePlan.prop 'checked'

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

      @ui.isUsePlan.prop 'checked', @model.params.isUsePlan

      @ui.btnToggleParams.trigger 'click' if @model.isShowParams

      @ui.form.validate
        rules:
          dBegin_:
            required: true
          dEnd_:
            required: true
        messages:
          dBegin_:
            required: 'Пожалуйста, укажите начальную дату.',
          dEnd_:
            required: 'Пожалуйста, укажите конечную дату.',

      @resize()

    templateHelpers: ->
      _.extend super,
        params: =>
          @model.params

  #-----------------------------------------------------------------------
  class Show.Data extends App.Views.Layout
    template: 'reports_dynamics/show/_data'

    modelEvents:
      'sync refresh': 'showData'

    regions:
      viewRegion: '[name=view-region]'

    showData: ->
      if @model.viewType is 1
        tableView = new Show.Table
          model: @model
        @viewRegion.show tableView
      else
        graphView = new Show.Graph
          model: @model
        @viewRegion.show graphView

    onShow: ->
      @showData()

    initialize: ->
      App.vent.on 'reports_dynamics:panel:resize', (height) =>
        @$el.css
          'padding-top': (height + 5) + 'px'

    onBeforeShow: ->
      @$el.css
        'padding-top': App.request('reports_dynamics:panel:height') + 5 + 'px'


  class Show.Table extends App.Views.ItemView
    template: 'reports_dynamics/show/_table'
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

      items = _.sortBy _items, (item) ->
        if item.idCategory
          CashFlow.entities.categories.get(item.idCategory).get('name')
        else
          null

      result = ''
      _.each items, (item) =>
        result = result + """
          <tr #{if item.items.length > 0 then 'data-tt-branch="true"' else ''}
              data-tt-id="#{if item.idCategory then item.idCategory else -parent}"
              #{if parent then 'data-tt-parent-id="' + parent + '"'} >
            <td style="white-space: nowrap">
              #{if item.idCategory then _.escape(CashFlow.entities.categories.get(item.idCategory).get('name')) else 'Другое'}
            </td>
          """

        total = 0

        _.each @model.getMonths(), (month) =>
          result = result + '<td class="sum">'

          if item[month]
            sum = Show.getValue(item[month], @model.valueType)
            total = total + sum
            result = result + s.numberFormat(sum, 0, '.', ' ')

          result = result + '</td>'

        result = result + """
            <td class="sum">
              #{s.numberFormat(total, 0, '.', ' ')}
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
        valueType: =>
          @model.valueType
        getMonths: =>
          @model.getMonths()
        getValue: (sum, valueType) ->
          Show.getValue(sum, valueType)
        renderRoot: =>
          @renderRows null

  class Show.Graph extends App.Views.ItemView
    template: 'reports_dynamics/show/_graph'
#    template: false
    className: 'container-fluid'

#    modelEvents:
#      'sync refresh': 'renderGraph'

    ui:
      graph: '[name=graph]'
      groupBy: '[name=groupBy]'
#      tooltip: '[name=tooltip]'

    events:
      'change @ui.groupBy': ->
        if @$('input[name=groupBy]:checked').val() is '1'
          @transitionStacked()
        else
          @transitionMultiples()

    renderGraph: ->
      dBegin = moment(@model.params.dBegin, 'YYYY-MM-DD').startOf('month')
      # Make data for graph. Collect ONLY first and second levels.
      @data = []
      # this is a month (YYYYMM)
      reg = /^\d{6}$/i
      months = @model.getMonths()
      _.each @model.get('items'), (item) =>
        if item.items.length > 0
          parent = item
          _.each item.items, (item) =>
            _.each Object.keys(item), (key) =>
              if  reg.test(key)
                value = Show.getValue(item[key], @model.valueType)
                parentValue = Show.getValue(parent[key], @model.valueType)
                categoryName = App.entities.categories.get(parent.idCategory).get('name')
                subCategoryName = if item.idCategory then App.entities.categories.get(item.idCategory).get('name') else 'Другое'
                if value isnt 0
                  @data.push
                    month: months.indexOf(key)
                    category: categoryName
                    value: value
                    title: """
                    <table>
                    <tbody>
                      <tr>
                        <td style="text-align: left; padding-right: 10px;">
                          #{subCategoryName}
                        </td>
                        <td style="text-align: right; white-space: nowrap">
                          #{s.numberFormat(value, 0, '.', ' ')}
                        </td>
                      </tr>
                      <tr>
                        <td style="text-align: left; padding-right: 10px;">
                          #{categoryName}
                        </td>
                        <td style="text-align: right; white-space: nowrap">
                          #{s.numberFormat(parentValue, 0, '.', ' ')}
                        </td>
                      </tr>
                    </tbody>
                    </table>
                    """

        else
          _.each Object.keys(item), (key) =>
            if reg.test(key)
              value = Show.getValue(item[key], @model.valueType)
              categoryName = App.entities.categories.get(item.idCategory).get('name')
              if value isnt 0
                @data.push
                  month: months.indexOf(key)
                  category: categoryName
                  value: value
                  title: "#{categoryName}: #{s.numberFormat(value, 0, '.', ' ')}"


      @ui.graph.empty()

      @margin =
        top: 20
        right: 60
        bottom: 20
        left: 170

      @width = @ui.graph.width() - @margin.left - @margin.right
      @height = Math.min(@ui.graph.width() * 9 / 16, window.innerHeight - 200) - @margin.top - @margin.bottom

      categories = []

      categoryNest = d3.nest()
      .key (item) ->
        item.category

      monthNest = d3.nest()
      .key (item) ->
        item.month

      dataByCategory = categoryNest.entries @data
      dataByMonth = monthNest.entries @data

      _.each dataByCategory, (category) ->
        category.sum = d3.sum(category.values, (item) ->
          item.value
        )

        # считаем максимальные месячные траты в группе
        mv = monthNest.entries(category.values).map (monthInCategory) ->
          d3.sum(monthInCategory.values, (item) ->
            item.value
          )

        category.maxByMonths = d3.max mv


      # отсортируем по возрастанию суммы в группе
      dataByCategory.sort (a, b) ->
        d3.ascending(a.sum, b.sum)


      # Сумма всех максимальных месячных трат по категориям (для формирования шкалы)
      @sumMaxByMonths = 0
      _.each dataByCategory, (category) =>
        categories.push category.key
        @sumMaxByMonths += category.maxByMonths
        #смещение группы в Multiples-графике
        category.offset = @sumMaxByMonths

      monthMax = 0
      _.each dataByMonth, (category) ->
        offset = 0
        offsetByCategory = []

        mt = monthNest.entries(category.values).map (monthInCategory) ->
          d3.sum(monthInCategory.values, (item) ->
            item.value
          )

        t = d3.max mt

        monthMax = t if t > monthMax

        category.values.sort (a, b) ->
          i1 = categories.indexOf(a.category)
          i2 = categories.indexOf(b.category)
          if i1 is i2
            b.value - a.value
          else
            i2 - i1


        # Смещение внутри групппы (для multi
        _.each category.values, (item) ->
          if not offsetByCategory[item.category]
            offsetByCategory[item.category] = 0
          item.valueOffset2 = offsetByCategory[item.category]
          offsetByCategory[item.category] += item.value

          item.valueOffset1 = offset
          offset += item.value

      @x = d3.scale.ordinal().domain(x for x in [0..months.length - 1]).rangeRoundBands([0, @width],
        .1)

      # Stacked
      @y_s = d3.scale.linear().domain([0, monthMax * 1.1]).range([@height, 0])
      # Для высоты элементов на графике
      @h_s = d3.scale.linear().domain([0, monthMax * 1.1]).range([0, @height])

      # Multiples
      @y_m = d3.scale.linear().domain([0, @sumMaxByMonths * 1.1]).range([0, @height])

      color = d3.scale.category20()

      xAxis = d3.svg.axis()
      .scale(@x)
      .orient("bottom")

      yAxis = d3.svg.axis()
      .scale(@y_s)
      .orient("left")
      .tickFormat(d3.format("d"))
      .tickSize(-@width)
      #      .tickPadding(10)

      #      color = ['#1f77b4', '#aec7e8', '#ff7f0e', '#ffbb78', '#2ca02c', '#98df8a', '#d62728', '#ff9896', '#9467bd', '#c5b0d5', '#8c564b', '#c49c94', '#e377c2', '#f7b6d2', '#7f7f7f', '#c7c7c7',
      #               '#bcbd22', '#dbdb8d', '#17becf', '#9edae5', '#393b79', '#5254a3', '#6b6ecf', '#9c9ede', '#637939', '#8ca252', '#b5cf6b', '#cedb9c', '#8c6d31', '#bd9e39', '#e7ba52', '#e7cb94',
      #               '#843c39', '#ad494a', '#d6616b', '#e7969c', '#7b4173', '#a55194', '#ce6dbd', '#de9ed6']

      @svg = d3.select(@ui.graph[0]).append("svg")
      .attr("width", @width + @margin.left + @margin.right)
      .attr("height", @height + @margin.top + @margin.bottom)
      .append("g")
      .attr("transform", "translate(" + @margin.left + "," + @margin.top + ")")

      @svg.append("g")
      .attr("class", "x axis")
      .call(xAxis)
      #      .selectAll("text")
      #      .attr("transform", "rotate(90)")
      #      .style("text-anchor", "start")

      @svg.select(".x.axis")
      .attr("transform", "translate(0," + @height + ")")
      .selectAll("text")
      .text (d, i) ->
        date = dBegin.clone().add(d, 'months')
        if date.month() is 0 or i is 0
          date.format('MMM YYYY')
        else
          date.format('MMM')


      @svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)

      group = @svg.selectAll(".group")
      .data(dataByCategory)
      .enter().append("g")
      .attr("class", "group")
      .attr("id", (d) ->
        d.key)
      .attr("transform", "translate(0,0)")

      group.append("text")
      .attr("class", "group-label")
      .attr("x", 0)
      .attr("y", @height + 100)
      .style("fill", (d) ->
#        color[categories.indexOf(d.key) % color.length])
        color(d.key))
      .text (d) ->
        d.key

      group.append("text")
      .attr("class", "group-sum")
      .attr("x", @width + 50)
      .attr("y", @height + 100)
      .style("fill", (d) ->
#        color[categories.indexOf(d.key) % color.length])
        color(d.key))
      .text (d) ->
        Math.floor(d.sum)


      body = $('html')[0]
      group.selectAll("rect")
      .data (d) ->
        d.values
      .enter().append("rect")
      .style("fill", (d) ->
#        color[categories.indexOf(d.category) % color.length]
        color(d.category)
      )
      .attr("title", (d) ->
        d.title
      )
      .attr("class", "rect")

      @$(".rect").tooltip
        container: 'body'
        placement: 'auto right'
        html: true

      # Этот кусок не обязателен. Он нужен только для скрытия названия категорий, которые не помещаются по высоте
      @svg.select(".y.axis")
      .attr("transform", "translate(" + (0 - @margin.left - 100) + ",0)")
      group
      .attr("transform", (d, i) =>
        "translate(0," + @y_m(d.offset * 1.1) + ")"
      )

      group.select(".group-label")
      .attr("y", 0)

      group.select(".group-sum")
      .attr("y", 0)

      group.selectAll("rect")
      .attr("height", (d) =>
        @y_m(d.value))
      .attr("width", @x.rangeBand())
      .attr("x", (d) =>
        @x(d.month))
      .attr("y", (d) =>
        -@y_m(d.value + d.valueOffset2))

      group.select(".group-label")
      .style("opacity", ->
        if (this.getBBox().height < this.parentNode.getBBox().height) then 1 else 0
      )

      group.select(".group-sum")
      .style("opacity", ->
        if (this.getBBox().height < this.parentNode.getBBox().height) then 1 else 0
      )

      #      @ui.groupBy.change()
      @transitionStacked()

    transitionStacked: ->
#      console.log 'transitionStacked'
      t = @svg.transition().duration(500)

      #      t.select(".x.axis").attr("transform", "translate(0," + @height + ")")
      t.select(".y.axis").attr("transform", "translate(0,0)")

      g = t.selectAll(".group").attr("transform", "translate(0,0)")

      g.selectAll("rect")
      .attr("x", (d) =>
        @x(d.month))
      .attr("y", (d) =>
        @y_s(d.value + d.valueOffset1))
      .attr("height", (d) =>
        @h_s(d.value))
      .attr("width", @x.rangeBand())

      g.select(".group-label").attr("y", @height + 100)
      g.select(".group-sum").attr("y", @height + 100)

    transitionMultiples: ->
      t = @svg.transition().duration(500)

      #      t.select(".x.axis").attr("transform", "translate(0," + @height + ")")
      t.select(".y.axis").attr("transform", "translate(" + (0 - @margin.left - @width) + ",0)")

      g = t.selectAll(".group")
      .attr("transform", (d, i) =>
        "translate(0," + @y_m(d.offset * 1.1) + ")"
      )

      g.selectAll("rect")
      .attr("height", (d) =>
        @y_m(d.value))
      .attr("width", @x.rangeBand())
      .attr("x", (d) =>
        @x(d.month))
      .attr("y", (d) =>
        -@y_m(d.value + d.valueOffset2))
      #      .style("opacity", 1)

      g.select(".group-label").attr("y", 0)
      g.select(".group-sum").attr("y", 0)

    onShow: ->
      @renderGraph()
