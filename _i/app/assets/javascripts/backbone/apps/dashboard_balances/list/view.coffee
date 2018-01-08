@CashFlow.module 'DashboardBalancesApp.List', (List, App, Backbone, Marionette, $, _) ->
  class List.Layout extends App.Views.Layout
    template: 'dashboard_balances/list/layout'

    regions:
      panelRegion: '[name=panel-region]'
      listRegion: '[name=list-region]'

    ui:
      dBalance: 'span[name=dBalance]'

    modelEvents:
      'sync:start': 'syncStart'
      'sync:stop': 'syncStop'

    syncStart: ->
      @addOpacityWrapper()

    syncStop: ->
      @addOpacityWrapper(false)
      @ui.dBalance.text moment(@model.params.dBalance, 'YYYY-MM-DD').format('DD.MM.YYYY')

    onDestroy: ->
      @addOpacityWrapper(false)

    templateHelpers: ->
      params: =>
        @model.params
  #-----------------------------------------------------------------------

  class List.Panel extends App.Views.ItemView
    template: 'dashboard_balances/list/_panel'

    ui:
      form: 'form'
      btnRefresh: '.btn[name=btnRefresh]'
      btnToggleParams: '.btn[name=btnToggleParams]'

      params: '[name=params]'
      dBalance: '[name=dBalance]'
      money: '[name=money]'
      isShowZeroBalance: '[name=isShowZeroBalance]'


    events:
      'click @ui.btnRefresh': 'refresh'
      'click @ui.btnToggleParams': 'toggleParams'
      'change @ui.money': 'refresh'
      'change @ui.isShowZeroBalance': ->
        @model.params.isShowZeroBalance = @ui.isShowZeroBalance.prop 'checked'
        @model.trigger 'refresh'


    toggleParams: ->
      @ui.params.slideToggle
        duration: 50

      $('.fa-caret-down, .fa-caret-right',
        @ui.btnToggleParams).toggleClass('fa-caret-down').toggleClass('fa-caret-right')

    refresh: ->
      return if not @ui.form.valid()

      dBalance = moment @ui.dBalance.datepicker('getDate')
      @model.params.dBalance = if dBalance.isValid() then dBalance.format('YYYY-MM-DD') else null

      @model.params.idMoney = numToJSON @ui.money.select2('val')
      @model.fetch()

    onRender: ->
      @ui.dBalance.datepicker()
      @ui.dBalance.datepicker('setDate',
        moment(@model.params.dBalance, 'YYYY-MM-DD').toDate()) if @model.params.dBalance

      @ui.money.select2()
      @ui.money.select2('val', @model.params.idMoney)

      @ui.isShowZeroBalance.prop 'checked', @model.params.isShowZeroBalance

      @ui.form.validate
        rules:
          dBalance_:
            required: true
        messages:
          dBalance_:
            required: 'Пожалуйста, укажите дату.',


    onDestroy: ->
      @ui.money.select2 'destroy'

  class List.Balances extends App.Views.ItemView
    getTemplate: ->
      if @model.get('accountBalances').length isnt 0 or @model.get('debtBalances').length isnt 0
        'dashboard_balances/list/_balances'
      else
        'dashboard_balances/list/_empty'

    #    template: 'dashboard_accounts_balances/list/_balances'

    modelEvents:
      'sync refresh': 'render'

    renderRow: (label, id, parent, balances) ->
      sums = ''
      symbols = ''
      # TODO use numberToMoney
      _.each balances, (balance) ->
        sums += """
          <div class="row">
            <div class="col-xs-12">
              #{App.Utilities.numberToMoney(balance.sum, balance.idMoney)}
            </div>
          </div>
          """

        symbols += """
          <div class="row">
            <div class="col-xs-12">
              #{CashFlow.entities.moneys.get(balance.idMoney).get('symbol')}
            </div>
          </div>
          """
      sums = '0' if sums is ''

      idAttr = if id then "data-tt-id='#{id}'" else ''
      parentAttr = if parent then "data-tt-parent-id='#{parent}'" else ''


      #style="white-space: nowrap"
      """
      <tr #{idAttr} #{parentAttr}>
        <td>
          <span class="content">
            #{label}
          </span>
        </td>
        <td class="sum">
          #{sums}
        </td>
        <td class="symbol">
          #{symbols}
        </td>
      </tr>
      """

    calculateTotal: (items) ->
      _totals = {}
      _.each items, (item) ->
        _.each item.balances, (balance) ->
          if not _totals[balance.idMoney]
            _totals[balance.idMoney] =
              idMoney: balance.idMoney
              sum: 0
          _totals[balance.idMoney].sum += balance.sum

      totals = []
      for key, obj of _totals
        totals.push obj
      totals


    onRender: ->
      view = @
      tbody = ''

      # Accounts
      # make a copy
      items = _.map(@model.get('accountBalances'), _.clone)

      # delete zero balances & sort
      if not @model.params.isShowZeroBalance
        _.each items, (item) ->
          item.balances = _.filter item.balances, (balance) ->
            balance.sum isnt 0

      # total
      totals = App.Entities.sortListByMoney(@calculateTotal(items))
      tbody += view.renderRow('<strong>Всего</strong>', 0, null, totals)

      _.each App.entities.accountTypes.models, (accountType) ->
        _items = _.filter items, (item) ->
          accountType.id is App.entities.accounts.get(item.idAccount).get('idAccountType') and item.balances.length > 0

        if _items.length > 0
          # totals for account type
          totals = App.Entities.sortListByMoney(view.calculateTotal(_items))

          tbody += view.renderRow(accountType.get('name'), accountType.id, null, totals)
          _.each _items, (item) ->
            item.balances = App.Entities.sortListByMoney item.balances
            tbody += view.renderRow(CashFlow.entities.accounts.get(item.idAccount).get('name'),
              'id' + item.idAccount, accountType.id, item.balances)


      @$('table[name=accountBalances] > tbody').append tbody
      @$('table[name=accountBalances]').treetable
        expandable: true
        clickableNodeNames: true
        stringCollapse: ''
        stringExpand: ''
        initialState: 'expanded'
        indent: 0
      #        indenterTemplate: '<div class="indenter"></div>'

      # Debts
      tbody = ''

      items = _.map(@model.get('debtBalances'), _.clone)
      _items = _.filter items, (item) ->
        item.debtType is 1 and item.balances.length > 0

      totals = App.Entities.sortListByMoney(view.calculateTotal(_items))

      tbody += view.renderRow('Мне должны', 1, null, totals)
      _.each _items, (item) ->
        item.balances = App.Entities.sortListByMoney item.balances
        tbody += view.renderRow(CashFlow.entities.contractors.get(item.idContractor).get('name'),
          'id' + item.idContractor, 1, item.balances)


      _items = _.filter items, (item) ->
        item.debtType is 2 and item.balances.length > 0

      totals = App.Entities.sortListByMoney(view.calculateTotal(_items))

      tbody += view.renderRow('Я должен', 2, null, totals)
      _.each _items, (item) ->
        item.balances = App.Entities.sortListByMoney item.balances
        tbody += view.renderRow(CashFlow.entities.contractors.get(item.idContractor).get('name'),
          'id' + item.idContractor, 2, item.balances)

      @$('table[name=debtBalances] > tbody').append tbody
      @$('table[name=debtBalances]').treetable
        expandable: true
        clickableNodeNames: true
        stringCollapse: ''
        stringExpand: ''
      #        initialState: 'expanded'
        indent: 0

      @$('tr.branch').addClass 'active'
