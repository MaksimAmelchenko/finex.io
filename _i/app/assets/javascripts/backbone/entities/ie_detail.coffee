@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.IEDetail extends Entities.Model
    idAttribute: 'idIEDetail'
    defaults:
      idUser: null
      idIE: null
      idContractor: null,
      idIEDetail: null
      idAccount: null
      idMoney: null
      idCategory: null
      idUnit: null
      sign: null
      dIEDetail: null
      reportPeriod: null
      quantity: null
      sum: null
      isNotConfirmed: false,
      note: ''
      tags: []
      permit: null
      idPlan: null
      nRepeat: null

    urlRoot: App.getServer() + '/cashflows/ie_details'

    initialize: ->
      new Backbone.Chooser(@)

    parse: (response, options)->
      if not _.isUndefined response.ieDetail
        response = response.ieDetail
      response

    isExpired: ->
      dIEDetail = moment(@get('dIEDetail'), 'YYYY-MM-DD').toDate()
      @get('isNotConfirmed') and dIEDetail.getTime() < Date.now()

  # --------------------------------------------------------------------------------

  class Entities.IEDetails extends Entities.Collection
    model: Entities.IEDetail
    url: 'cashflows/ie_details'

    initialize: ->
      new Backbone.MultiChooser(@)

      # change a date or make a operation from a planned operation
      @on 'change:dIEDetail change:idPlan', =>
        @sort()

      @searchText = ''

      @isUseFilters = false
      @filters =
        dBegin: null
        dEnd: null
        sign: null
        contractors: []
        accounts: []
        categories: []
        tags: []

    resetFilters: ->
      @filters.contractors = []
      @filters.accounts = []
      @filters.categories = []
      @filters.tags = []

    comparator: (ieItem1, ieItem2) ->
      isPlan1 = if ieItem1.get('idPlan') then true else false
      isPlan2 = if ieItem2.get('idPlan') then true else false

      if isPlan1 is isPlan2
        dIEItem1 = moment(ieItem1.get('dIEDetail'), 'YYYY-MM-DD').toDate().getTime()
        dIEItem2 = moment(ieItem2.get('dIEDetail'), 'YYYY-MM-DD').toDate().getTime()
        if dIEItem1 > dIEItem2
          -1
        else
          if dIEItem1 < dIEItem2
            1
          else
            if ieItem1.id and ieItem2.id and ieItem1.id > ieItem2.id
              -1
            else
              if ieItem1.id and ieItem2.id and ieItem1.id < ieItem2.id
                1
              else
                if ieItem1.cid > ieItem2.cid
                  -1
                else
                  if ieItem1.cid < ieItem2.cid
                    1
                  else
                    0
      else
        if isPlan1
          -1
        else
          1

    parse: (response, options)->
      @total = response.metadata.total
      @totalPlanned = response.metadata.totalPlanned
      @limit = response.metadata.limit
      @offset = response.metadata.offset
      response.ieDetails

    data: ->
      result =
        limit: @limit
        offset: @offset
        searchText: @searchText
      if @isUseFilters
        result = $.extend result,
          dBegin: @filters.dBegin
          dEnd: @filters.dEnd
          sign: @filters.sign
          contractors: @filters.contractors.toString()
          accounts: @filters.accounts.toString()
          categories: @filters.categories.toString()
          tags: @filters.tags.toString()
      result

  # --------------------------------------------------------------------------------

  API =
    newIEDetailEntity: ->
      new Entities.IEDetail
        idMoney: (App.request 'default:money')?.get('idMoney')
        sign: -1
        dIEDetail: App.request 'default:date'
        reportPeriod: App.request 'default:reportPeriod'
        quantity: 1
  #        idUnit: 1 # шт

    getIEDetailEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.ieDetails
        App.entities.ieDetails = new Entities.IEDetails
        force = true

      ieDetails = App.entities.ieDetails

      if ieDetails.length is 0
        force = true

      if force
        selected = ieDetails.getChosen()
        ieDetails.fetch
          reset: true
          success: ->
            ieDetails.chooseByIds selected

      ieDetails

  App.reqres.setHandler 'ie:detail:new:entity', ->
    API.newIEDetailEntity()

  App.reqres.setHandler 'ie:detail:entities', (options)->
    API.getIEDetailEntities(options)


