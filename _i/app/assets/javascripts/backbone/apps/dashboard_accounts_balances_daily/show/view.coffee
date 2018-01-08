@CashFlow.module 'DashboardAccountsBalancesDailyApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Layout extends App.Views.Layout
    template: 'dashboard_accounts_balances_daily/show/layout'

    regions:
      panelRegion: '[name=panel-region]'
      graphRegion: '[name=graph-region]'

    ui:
      dBegin: '[name=dBegin]'
      dEnd: '[name=dEnd]'

    modelEvents:
      'sync:start': 'syncStart'
      'sync:stop': 'syncStop'

    syncStart: ->
      @addOpacityWrapper()

    syncStop: ->
      @ui.dBegin.text moment(@model.params.dBegin, 'YYYY-MM-DD').format('DD.MM.YYYY')
      @ui.dEnd.text moment(@model.params.dEnd, 'YYYY-MM-DD').format('DD.MM.YYYY')
      @addOpacityWrapper(false)

    onDestroy: ->
      @addOpacityWrapper(false)

  # --------------------------------------------------------------------------------

  class Show.Panel extends App.Views.Layout
    template: 'dashboard_accounts_balances_daily/show/_panel'

    ui:
      form: 'form'
      btnRefresh: '.btn[name=btnRefresh]'
      btnToggleParams: '.btn[name=btnToggleParams]'

      params: '[name=params]'

      dBegin: '[name=dBegin]'
      dEnd: '[name=dEnd]'
      money: '[name=money]'

    events:
      'click @ui.btnRefresh': 'refresh'
      'click @ui.btnToggleParams': 'toggleParams'
      'change @ui.money': 'refresh'

    refresh: ->
      return if not @ui.form.valid()

      dBegin = moment @ui.dBegin.datepicker('getDate')
      @model.params.dBegin = if dBegin.isValid() then dBegin.format('YYYY-MM-DD') else null
      dEnd = moment @ui.dEnd.datepicker('getDate')
      @model.params.dEnd = if dEnd.isValid() then dEnd.format('YYYY-MM-DD') else null

      if dBegin > dEnd
        showError 'Пожалуйста, укажите начальную дату меньше, чем конечную.'
        return

      @model.params.idMoney = numToJSON @ui.money.select2('val')

      #      @model.params.accountsUsingType = parseInt(@ui.accountsUsingType.select2 'val')
      #      @model.params.accounts = _.map @ui.accounts.select2('val'), (item) ->
      #        parseInt item

      @model.fetch()

    onDestroy: ->
      @ui.money.select2 'destroy'
    #      @ui.accountsUsingType.select2 'destroy'

    toggleParams: ->
      @ui.params.slideToggle
        duration: 50
      $('.fa-caret-down, .fa-caret-right',
        @ui.btnToggleParams).toggleClass('fa-caret-down').toggleClass('fa-caret-right')

    onRender: ->
      @ui.dBegin.datepicker()
      @ui.dBegin.datepicker('setDate',
        moment(@model.params.dBegin, 'YYYY-MM-DD').toDate()) if @model.params.dBegin
      @ui.dEnd.datepicker()
      @ui.dEnd.datepicker('setDate',
        moment(@model.params.dEnd, 'YYYY-MM-DD').toDate()) if @model.params.dEnd

      @ui.money.select2()
      @ui.money.select2('val', @model.params.idMoney)


      #      @ui.accountsUsingType.select2()
      #      @ui.accountsUsingType.select2 'val', @model.params.accountsUsingType
      #      @ui.accounts.select2
      #        placeholder: 'Все'
      #      @ui.accounts.select2('val', @model.params.accounts)

      @ui.form.validate
        rules:
          dBegin_:
            required: true
          dEnd_:
            required: true
        messages:
          dBegin_:
            required: 'Пожалуйста, укажите начальную дату',
          dEnd_:
            required: 'Пожалуйста, укажите конечную дату',

  # --------------------------------------------------------------------------------

  class Show.Graph extends App.Views.ItemView
    template: 'dashboard_accounts_balances_daily/show/_graph'

    ui:
      graph: '[name=graph]'
      tooltip: '[name=tooltip]'

    modelEvents:
      'sync': 'renderGraphs'


    renderGraphs: ->
      @ui.graph.empty()
      moneys = d3.nest()
      .key (d) ->
        d.idMoney
      .entries @model.get 'balances'

      # sort according to the list of moneys in the reference
      c = _.map App.request('enabled:money:entities'), (money) ->
        money.get('idMoney')

      moneys = _.sortBy moneys, (item) ->
        _.indexOf(c, parseInt(item.key))

      _.each moneys, (money) =>
        @renderGraph(money.key, money.values)

    renderGraph: (idMoney, items)->
      margin =
        top: 10
        right: 10
        bottom: 80
        left: 70

      marginContext =
        top: 250 # !!!!!!!!!
        right: 10
        bottom: 20
        left: 70

      width = @ui.graph.width() - margin.left - margin.right
      # !!!!!!!!!
      height = 300 - margin.top - margin.bottom
      heightContext = 300 - marginContext.top - marginContext.bottom

      x = d3.time.scale().range([0, width])
      xContext = d3.time.scale().range([0, width])
      y = d3.scale.linear().range([height, 0])
      yContext = d3.scale.linear().range([heightContext, 0])

      RU = d3.locale
        "decimal": ","
        "thousands": "\xa0"
        "grouping": [3]
        "money": ["", " руб."]
        "dateTime": "%A, %e %B %Y г. %X"
        "date": "%d.%m.%Y"
        "time": "%H:%M:%S"
        "periods": ["AM", "PM"]
        "days": ["воскресенье", "понедельник", "вторник", "среда", "четверг", "пятница", "суббота"]
        "shortDays": ["вс", "пн", "вт", "ср", "чт", "пт", "сб"]
        "months": ["январь", "февраль", "март", "апрель", "май", "июнь", "июль", "август",
                   "сентябрь", "октябрь", "ноябрь", "декабрь"]
        "shortMonths": ["янв", "фев", "мар", "апр", "май", "июн", "июл", "авг", "сен", "окт", "ноя",
                        "дек"]

      customTimeFormat = RU.timeFormat.multi([
        [".%L", (d)  -> d.getMilliseconds()]
        [":%S", (d)  -> d.getSeconds()]
        ["%I:%M", (d) -> d.getMinutes()]
        ["%I %p", (d) -> d.getHours()],
        ["%d,%a", (d) -> d.getDay() && d.getDate() != 1],
        ["%d %b", (d) -> d.getDate() != 1],
        ["%b", (d) -> d.getMonth()],
        ["%Y", -> true]
      ])

      xAxis = d3.svg.axis().scale(x).orient("bottom").ticks(8).tickFormat(customTimeFormat)

      yAxis = d3.svg.axis().scale(y).orient("left")

      xAxisContext = d3.svg.axis().scale(xContext).orient("bottom").ticks(5).tickFormat(customTimeFormat)

      line = d3.svg.line()
      #      .interpolate("basis")
      .interpolate("linear")
      #      .interpolate("step")
      .x (d) ->
        x(d.date)
      .y (d) ->
        y(d.sum)

      lineContext = d3.svg.line()
      #      .interpolate("basis")
      .interpolate("step")
      .x (d) ->
        xContext(d.date)
      .y (d) ->
        yContext(d.sum)

      color = d3.scale.category10()

      accountsNest = d3.nest().key (d) ->
        d.idAccount

      _.each(items, (item) ->
        item.date = moment(item.dBalance, 'YYYY-MM-DD').toDate()
      )

      x.domain([moment(@model.params.dBegin, 'YYYY-MM-DD').toDate(),
                moment(@model.params.dEnd, 'YYYY-MM-DD').toDate()])

      mm = d3.extent(items, (d) ->
        d.sum
      )
      # Раздвинули область видемости на 1% и показали нулевой уровень
      mm[0] = Math.min(mm[0] * 1.01, 0)
      mm[1] = Math.max(mm[1] * 1.01, 0)
      #      mm[1] = mm[1] * 1.01;
      y.domain(mm)

      svg = d3.select(@ui.graph[0]).append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      #      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")


      # Область видемости
      svg.append("defs").append("clipPath")
      .attr("id", "clip")
      .append("rect")
      .attr("width", width)
      .attr("height", height)

      focus = svg.append("g")
      .attr("class", "focus")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

      focus.selectAll('path')
      .data(accountsNest.entries(items))
      .enter()
      .append("path")
      .attr("class", (d) ->
        if d.key is '0' then "line total" else 'line'
      )
      .style("stroke", (d, i) ->
        if d.key isnt '0'
          color d.key
        else
          false
      )
      .attr("d", (d) ->
        line(d.values)
      )
      .on 'mousemove', (d, i) =>
        @ui.tooltip
        .css {
          left: d3.event.clientX + 10
          top: d3.event.clientY
        }
      .on 'mouseover', (d, i) =>
        idAccount = Number d.key
        @ui.tooltip.html(
          if idAccount is 0 then 'Всего' else App.entities.accounts.get(idAccount).get('name')
        )
        .css {
          left: d3.event.clientX + 10
          top: d3.event.clientY
        }
        .show()
      .on 'mouseout', =>
        @ui.tooltip.hide()

      focus.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)

      focus.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text(App.entities.moneys.get(+idMoney).get('name'))

      if mm[0] < 0
        focus.append("g")
        .attr("class", "zerolevel")
        .append("line")
        .attr("x1", 0)
        .attr("x2", width)
        .attr("y1", y(0))
        .attr("y2", y(0))

      brush = d3.svg.brush()
      .x(xContext)
      .on("brush", ->
        x.domain(if brush.empty() then xContext.domain() else brush.extent())
        focus.selectAll(".line").attr("d", (d) ->
          line(d.values)
        )
        focus.select(".x.axis").call(xAxis)
      )

      context = svg.append("g")
      .attr("class", "context")
      .attr("transform", "translate(" + marginContext.left + "," + marginContext.top + ")")


      t = _.where(items, {idAccount: 0})

      xContext.domain(x.domain())

      yContext.domain(d3.extent(t, (item) ->
        item.sum
      ))

      context.append("path")
      .datum(t)
      .attr("class", "line")
      .attr("d", lineContext)

      context.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + heightContext + ")")
      .call(xAxisContext)

      context.append("g")
      .attr("class", "x brush")
      .call(brush)
      .selectAll("rect")
      .attr("y", -6)
      .attr("height", heightContext + 7)

    onShow: ->
      if @model.get('balances').length is 0
        @ui.graph.html """
          <div class="well well-sm text-center">
            Нет данных
          </div>
        """
      else
        @renderGraphs()
