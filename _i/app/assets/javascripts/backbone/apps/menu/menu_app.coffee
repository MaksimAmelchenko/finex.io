@CashFlow.module 'MenuApp', (MenuApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    list: ->
      new MenuApp.List.Controller
#        region: App.menuRegion
        region: App.leftPanelRegion


  MenuApp.on 'start', () ->
    API.list()

#    $('.minifyme').on 'click', (e) ->
#      e.preventDefault()
#      body = $('body')
#      body.toggleClass 'minified'
#      body.removeClass 'hidden-menu'
#      $('html').removeClass 'hidden-menu-mobile-lock'
