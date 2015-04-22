@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.IEDetail extends Entities.Model
    idAttribute: 'idIEDetail'
    defaults:
      idUser: null
      idIE: null
      idContractor: null,
      idIEDetail: null
      idAccount: null
      idCurrency: null
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

    urlRoot: App.getServer() + '/cashflows/ie_details'

    initialize: ->
      new Backbone.Chooser(@)

    parse: (response, options)->
      if not _.isUndefined response.ieDetail
        response = response.ieDetail
      response

    isExpired: ->
      @get('isNotConfirmed') and moment(@get('dIEDetail'), 'YYYY-MM-DD').toDate().getTime() < Date.now()

  #-----------------------------------------------------------------------
  class Entities.IEDetails extends Entities.Collection
    model: Entities.IEDetail
    url: 'cashflows/ie_details'

    initialize: ->
      new Backbone.MultiChooser(@)
      @.on 'model:change', =>
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

    #    comparator: (ieDetail) ->
    #      -Date.parseExact(ieDetail.get('dIEDetail'), 'yyyy-MM-dd').getTime()
    comparator: (ieDetail1, ieDetail2) ->
      dIEDetail1 = moment(ieDetail1.get('dIEDetail'), 'YYYY-MM-DD').toDate().getTime()
      dIEDetail2 = moment(ieDetail2.get('dIEDetail'), 'YYYY-MM-DD').toDate().getTime()
      if dIEDetail1 > dIEDetail2
        -1
      else
        if dIEDetail1 < dIEDetail2
          1
        else
          if ieDetail1.id and ieDetail2.id and ieDetail1.id > ieDetail2.id
            -1
          else
            if ieDetail1.id and ieDetail2.id and ieDetail1.id < ieDetail2.id
              1
            else
              if ieDetail1.cid > ieDetail2.cid
                -1
              else
                if ieDetail1.cid < ieDetail2.cid
                  1
                else
                  0

    parse: (response, options)->
      @total = response.metadata.total
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


