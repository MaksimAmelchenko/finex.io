@CashFlow.module 'HeaderApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Controller extends App.Controllers.Application

    initialize: (options) ->
#      debugger
      @layout = @getLayoutView()

      @listenTo @layout, 'show', =>
        @showProjectsList()
      #        @showLogo()
      #        @showNav()

      @show @layout

    #    showLogo: ->
    #      logoView = @getLogoView()
    #      @show logoView,
    #        region: @layout.logoRegion
    #
    #    showNav: ->
    #      navView = @getNavView()
    #      @show navView,
    #        region: @layout.navRegion

    showProjectsList: ->
      view = new Show.Project
        collection: App.request 'project:entities'

      @show view,
        region: @layout.projectRegion

#    showProject: (project) ->
#      view = new Show.Project
#        model: project
#
#      @show view,
#        region: @layout.projectRegion

#    getProjectView: (project) ->

    getLayoutView: ->
      new Show.Layout

#    getLogoView: ->
#      new Show.Logo
#
#    getNavView: ->
#      new Show.Nav


