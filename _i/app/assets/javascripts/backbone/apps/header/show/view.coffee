@CashFlow.module 'HeaderApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Layout extends App.Views.Layout
    template: 'header/show/layout'

    ui:
      btnLogout: '[name=btnLogout]'
      btnToggleMenu: '[name=btnToggleMenu]'

    events:
      'click @ui.btnToggleMenu': 'toggleMenu'
      'click @ui.btnLogout': (e)->
        e.preventDefault()
        sessionStorage.clear()

        App.xhrRequest
          type: 'PUT'
          url: 'logout'

        callback = ->
          window.location.href = '/'
        setTimeout callback, 100


    toggleMenu: (e) ->
      e.preventDefault()
      $('html').toggleClass 'hidden-menu-mobile-lock'
      $('body')
      .toggleClass 'hidden-menu'
      .removeClass 'minified'
