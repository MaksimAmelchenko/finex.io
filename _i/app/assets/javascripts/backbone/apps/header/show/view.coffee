@CashFlow.module 'HeaderApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Layout extends App.Views.Layout
    template: 'header/show/layout'

    regions:
      projectRegion: '[name=project]'
    #      logoRegion: "#logo-region"
    #      navRegion: "#nav-region"


    #  class Show.Logo extends App.Views.ItemView
    #    template: 'header/show/_logo'
    #
    #  class Show.Nav extends App.Views.ItemView
    #    template: 'header/show/_nav'
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


  class Show.Project extends App.Views.ItemView
    template: 'header/show/_project'
    tagName: 'li'

    collectionEvents:
      'add change:name remove reset': 'render'

    events:
      'click li > a': (e) ->
        idProject = Number $(e.currentTarget).parent().data('idProject')
        App.execute 'use:project', idProject if idProject isnt App.request 'active:project'
        e.preventDefault()

    initialize: ->
      App.vent.on 'change:active:project', =>
        @render()
