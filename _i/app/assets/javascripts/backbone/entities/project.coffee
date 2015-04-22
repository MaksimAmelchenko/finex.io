@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Project extends Entities.Model
    idAttribute: 'idProject'
    urlRoot: App.getServer() + '/projects'

    initialize: ->
      new Backbone.Chooser(@)

    defaults:
      idUser: null
      idProject: null
      name: ''
      writers: []
      note: ''

    parse: (response, options)->
      if not _.isUndefined response.project
        response = response.project
      response

  class Entities.Projects extends Entities.Collection
    model: Entities.Project
    url: 'projects'

    parse: (response, options)->
      response.projects

    initialize: ->
      new Backbone.SingleChooser(@)
      @on 'change:name', =>
        @sort()

    comparator: (project) ->
      project.get('name')

  API =
    newProjectEntity: ->
      new Entities.Project

    getProjectEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.projects
        App.entities.projects = new Entities.Projects
        force = true

      projects = App.entities.projects

      if force
#        selected = projects.getChosen()
        projects.fetch
          reset: true
#          success: ->
#            projects.choose selected

      projects


  App.reqres.setHandler 'project:new:entity', ->
    API.newProjectEntity()

  App.reqres.setHandler 'project:entities', (options)->
    API.getProjectEntities(options)

  App.reqres.setHandler 'active:project', ->
    App.session.idProject
