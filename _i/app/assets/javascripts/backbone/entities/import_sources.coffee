@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.ImportSource extends Entities.Model
    idAttribute: 'idImportSource'

    defaults:
      idImportSource: null
      name: ''
      note: ''
      importSourceType: []

    parse: (response, options)->
      if not _.isUndefined response.importSource
        response = response.importSource
      response

  class Entities.ImportSources extends Entities.Collection

    model: Entities.ImportSource

    parse: (response, options)->
      response.importSources
