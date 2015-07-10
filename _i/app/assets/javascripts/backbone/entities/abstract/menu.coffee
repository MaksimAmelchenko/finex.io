@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.MenuItem extends  Entities.Model
    initialize: ->
      new Backbone.Chooser(@)

      items = @get 'items'
      if items
        @items = new Entities.MenuItems items
        @unset 'items'

  class Entities.MenuItems extends Entities.Collection
    model: Entities.MenuItem

    getMenuItem: (attrValue, attribute = 'id') ->
      obj = {}
      obj[attribute] = attrValue
      menuItem = undefined

      @models.some (mi) ->
        if mi.attributes[attribute] is attrValue
          menuItem = mi
        else
          menuItem = mi.items.getMenuItem(attrValue, attribute) if mi.items

      menuItem

  API =
  # @formatter:off
    getMenu: ->
      new Entities.MenuItems [
        {label: 'Итоги', id: 'dashboard', url: '#dashboard', icon: 'fa fa-lg fa-fw fa-tachometer'}
        {
          label: 'Денежные потоки', id: 'cashFlows', url: '#', icon: 'fa fa-lg fa-fw fa-random',
          items: [
            {
              label: 'Доходы и расходы', id: 'ies', url: '#', icon: 'fa fa-fw fa-flag',
              items: [
                {label: 'Потоки', id: 'ies_list', url: '#cashflows/ies/list', icon: 'fa fa-fw fa-th-list'}
                {label: 'Операции', id: 'ies_details', url: '#cashflows/ies/details', icon: 'fa fa-lg fa-fw fa-list'}
              ]
            }
            {label: 'Долги', id: 'debts', url: '#cashflows/debts', icon: 'fa fa-lg fa-fw fa-gift'}
            {label: 'Переводы', id: 'transfers', url: '#cashflows/transfers', icon: 'fa fa-lg fa-fw fa-long-arrow-right'}
            {label: 'Обмен валюты', id: 'exchanges', url: '#cashflows/exchanges', icon: 'fa fa-lg fa-fw fa-exchange'}
          ]
        }
        {label: 'Планирование', id: 'plans', url: '#plans', icon: 'fa fa-lg fa-fw fa-calendar'}
#        {label: 'Бюджет', id: 'budget', url: '#budget', icon: 'fa fa-lg fa-fw fa-calculator'}
        {
          label: 'Отчеты', id: 'reports', url: '#', icon: 'fa fa-lg fa-fw fa-file-text-o',
          items: [
            {label: 'Динамика', id: 'dynamics', url: '#reports/dynamics', icon: 'fa fa-lg fa-fw fa-line-chart'}
            {label: 'Распределение', id: '', url: '#reports/distribution', icon: 'fa fa-lg fa-fw fa-pie-chart'}
          ]
        }
        {
          label: 'Справочники', id: 'references', url: '#', icon: 'fa fa-lg fa-fw fa-book',
          items: [
            {label: 'Счета', id: 'accounts', url: '#references/accounts', icon: 'fa fa-lg fa-fw fa-credit-card'}
            {label: 'Категории', id: 'categories', url: '#references/categories', icon: 'fa fa-lg fa-fw fa-sitemap'}
            {label: 'Контрагенты', id: 'contractors', url: '#references/contractors', icon: 'fa fa-lg fa-fw fa-users'}
            {label: 'Единицы измерения', id: 'units', url: '#references/units', icon: 'fa fa-lg fa-fw fa-cubes'}
            {label: 'Теги', id: 'tags', url: '#references/tags', icon: 'fa fa-lg fa-fw fa-tags'}
            {label: 'Валюты', id: '', url: '#references/moneys', icon: 'fa fa-lg fa-fw fa-money'}
            {label: 'Проекты', id: 'projects', url: '#references/projects', icon: 'fa fa-lg fa-fw fa-suitcase'}
          ]
        }
        {
          label: 'Данные', id: 'database', url: '#', icon: 'fa fa-lg fa-fw fa-database',
          items: [
            {label: 'Импорт', id: 'import', url: '#import', icon: 'fa fa-lg fa-fw fa-cloud-upload'}
#            {label: 'Экспорт', id: ' export', url: '#export', icon: 'fa fa-lg fa-fw fa-cloud-download'}
          ]
        }
        {label: 'Пользователи', id: 'users', url: '#users', icon: 'fa fa-lg fa-fw fa-users'}
      ]
  # @formatter:on

  App.reqres.setHandler 'menu:entities', ->
    if !App.entities.menu
      App.entities.menu = API.getMenu()

    App.entities.menu


