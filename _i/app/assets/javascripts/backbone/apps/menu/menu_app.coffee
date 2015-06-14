@CashFlow.module 'MenuApp', (MenuApp, App, Backbone, Marionette, $, _) ->
  # для построения меню нужно дождать доп.данных, поэтому запускаем модуль вручную
  @startWithParent = false

  API =
    list: ->
      new MenuApp.List.Controller
        region: App.leftPanelRegion


  MenuApp.on 'start', () ->
    API.list()

  # --------------------------------------------------------------------------------

  App.commands.setHandler 'menu:set:badge', (idMenuItem, badge, title) ->
    menu = App.request('menu:entities')
    mi = menu.getMenuItem(idMenuItem)
    if mi
      mi.set
        badge: badge
        badgeTitle: title

  App.commands.setHandler 'menu:set:badges', ->
    _.each App.entities.badges, (badge) ->
      App.execute 'menu:set:badge', badge.menuItem, badge.value, badge.title
