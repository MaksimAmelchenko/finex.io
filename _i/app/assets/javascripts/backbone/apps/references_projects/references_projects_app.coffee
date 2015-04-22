@CashFlow.module 'ReferencesProjectsApp', (ReferencesProjectsApp, App, Backbone, Marionette, $, _) ->
  class ReferencesProjectsApp.Router extends Marionette.AppRouter
    appRoutes:
      'references/projects': 'list'

    before: ->
#      App.vent.trigger 'nav:main:choose', 'references'

  API =
    list: ->
#      App.execute 'references:list', 'accounts'
      ReferencesProjectsApp.list()

  App.addInitializer ->
    new ReferencesProjectsApp.Router
      controller: API

  @list = (region, project) ->
    new ReferencesProjectsApp.List.Controller
#        region: region
      project: project


  @edit = (project, region) ->
    new ReferencesProjectsApp.Edit.Controller
      project: project
      region: region

  @copy = (config, region) ->
    new ReferencesProjectsApp.Copy.Controller
      config: config
      region: region

  @merge = (config, region) ->
    new ReferencesProjectsApp.Merge.Controller
      config: config
      region: region

  # -- Exchange Edit ----------------------


  App.reqres.setHandler 'project:edit', (project, region = App.request 'dialog:region') ->
    isNew = project.isNew()
    editController = ReferencesProjectsApp.edit project, region

    editController.on 'form:after:save', (model) ->
      if isNew
        projects = App.request 'project:entities'
        projects.add model
        projects.choose model
      editController.form.formLayout.trigger 'dialog:close'

    editController

  #  App.vent.on 'nav:references:choose:accounts', (region) ->
  #    App.navigate 'references/accounts'
  #    ReferencesAccountsApp.list region

  # -----------------------------------------------------
  # config:
  # idProjectFrom - копируемый проект
  App.reqres.setHandler 'project:copy', (config, region = App.request 'dialog:region') ->
    copyController = ReferencesProjectsApp.copy config, region

    copyController.on 'form:after:save', ->
      copyController.form.formLayout.trigger 'dialog:close'

    copyController


  # -----------------------------------------------------
  # config:
  # idTargetProject - целевой проект, куда будут копироваться остальные проекты
  App.reqres.setHandler 'project:merge', (config, region = App.request 'dialog:region') ->
    mergeController = ReferencesProjectsApp.merge config, region

    mergeController.on 'form:after:save', ->
      mergeController.form.formLayout.trigger 'dialog:close'

    mergeController
