@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.IE extends Entities.Model
    idAttribute: 'idIE'
    urlRoot: App.getServer() + '/cashflows/ies'

    initialize: ->
      new Backbone.Chooser(@)

    mutators:
      dIE: ->
        ieDetail = _.max @get('ieDetails'), (ieDetail) ->
          moment(ieDetail.dIEDetail, 'YYYY-MM-DD').toDate().getTime()
        if ieDetail.dIEDetail
          ieDetail.dIEDetail
        else
          if @get('dSet') then moment(@get('dSet'), 'YYYY-MM-DD HH:mm:ss').format('YYYY-MM-DD')

      accounts: ->
        accounts = _.uniq(_.pluck(@get('ieDetails'), 'idAccount'))
        _.map accounts, (idAccount) ->
          App.entities.accounts.get(idAccount).get('name')


      categories: ->
        categories = _.pluck(@get('ieDetails'), 'idCategory')
        categories = _.map categories, (idCategory) ->
          App.entities.categories.get(idCategory).topLevel().get('name')

        _.uniq categories

    defaults:
      idIE: null
      idUser: null
      idContractor: null
      ieDetails: []
      note: ''
      tags: []
      dSet: null

    parse: (response, options)->
      if not _.isUndefined response.ie
        response = response.ie
      response

    getMoneys: ->
      App.Entities.sortListByMoney(_.uniq(_.pluck(@get('ieDetails'), 'idMoney')))

    getBalance: ->
      balance = {}

      _.each @get('ieDetails'), (detail) ->
        balance[detail.idMoney] or= {total: 0}

        if detail.sign is 1
          balance[detail.idMoney]['income'] or= 0
          balance[detail.idMoney]['income'] += detail.sum

        if detail.sign is -1
          balance[detail.idMoney]['expense'] or= 0
          balance[detail.idMoney]['expense'] += detail.sum

        balance[detail.idMoney]['total'] += detail.sign * detail.sum

      balance

  # --------------------------------------------------------------------------------

  class Entities.IEs extends Entities.Collection
    model: Entities.IE
    url: 'cashflows/ies'

    initialize: ->
      new Backbone.MultiChooser(@)
      @on 'change:ieDetails', =>
        @sort()

      @searchText = ''

      @isUseFilters = false
      @filters =
        dBegin: null
        dEnd: null
        contractors: []
        accounts: []
        tags: []

    resetFilters: ->
      @filters.contractors = []
      @filters.accounts = []
      @filters.tags = []

    comparator: (ie1, ie2) ->
      dIE1 = moment(ie1.get('dIE'), 'YYYY-MM-DD').toDate().getTime()
      dIE2 = moment(ie2.get('dIE'), 'YYYY-MM-DD').toDate().getTime()
      if dIE1 > dIE2
        -1
      else
        if dIE1 < dIE2
          1
        else
          if ie1.id > ie2.id
            -1
          else
            if ie1.id < ie2.id
              1
            else
              0

    parse: (response, options)->
      @total = response.metadata.total
      @limit = response.metadata.limit
      @offset = response.metadata.offset
      response.ies

    data: ->
      result =
        limit: @limit
        offset: @offset
        searchText: @searchText
      if @isUseFilters
        result = $.extend result,
          dBegin: @filters.dBegin
          dEnd: @filters.dEnd
          contractors: @filters.contractors.toString()
          accounts: @filters.accounts.toString()
          tags: @filters.tags.toString()
      result

  # --------------------------------------------------------------------------------

  API =
    newIEEntity: ->
      new Entities.IE

    getIEEntity: (idIE) ->
      ie = new Entities.IE
        idIE: idIE

      ie.fetch()
      ie

    getIEEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.ies
        App.entities.ies = new Entities.IEs
        force = true

      ies = App.entities.ies

      if ies.length is 0
        force = true

      if force
        selected = ies.getChosen()
        ies.fetch
          reset: true
          success: ->
            ies.chooseByIds selected
      ies


  App.reqres.setHandler 'ie:new:entity', ->
    API.newIEEntity()

  App.reqres.setHandler 'ie:entity', (idIE)  ->
    API.getIEEntity idIE

  App.reqres.setHandler 'ie:entities', (options)->
    API.getIEEntities(options)
