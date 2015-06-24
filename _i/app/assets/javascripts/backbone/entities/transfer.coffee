@CashFlow.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->
  class Entities.Transfer extends Entities.Model
    idAttribute: 'idTransfer'
    urlRoot: App.getServer() + '/cashflows/transfers'

    initialize: ->
      new Backbone.Chooser(@)

    defaults:
      idTransfer: null
      idUser: null
      dTransfer: null
      reportPeriod: null
      note: ''
      idAccountFrom: null
      sum: null
      idMoney: null
      idAccountTo: null
      isFee: false
      idAccountFee: null
      fee: null
      idMoneyFee: null
      tags: []
      idPlan: null
      nRepeat: null


    parse: (response, options)->
      if not _.isUndefined response.transfer
        response = response.transfer
      response

  # --------------------------------------------------------------------------------

  class Entities.Transfers extends Entities.Collection

    model: Entities.Transfer
    url: 'cashflows/transfers'
    initialize: ->
      new Backbone.MultiChooser(@)

      @on 'change:dTransfer change:idPlan', =>
        @sort()

      @searchText = ''

      @isUseFilters = false
      @filters =
        dBegin: null
        dEnd: null
        accountsFrom: []
        accountsTo: []
        tags: []

    resetFilters: ->
      @filters.accountsFrom = []
      @filters.accountsTo = []
      @filters.tags = []

    comparator: (transfer1, transfer2) ->
      isPlan1 = if transfer1.get('idPlan') then true else false
      isPlan2 = if transfer2.get('idPlan') then true else false

      if isPlan1 is isPlan2
        dTransfer1 = moment(transfer1.get('dTransfer'), 'YYYY-MM-DD').toDate().getTime()
        dTransfer2 = moment(transfer2.get('dTransfer'), 'YYYY-MM-DD').toDate().getTime()
        if dTransfer1 > dTransfer2
          -1
        else
          if dTransfer1 < dTransfer2
            1
          else
            idTransfer1 = transfer1.get('idTransfer')
            idTransfer2 = transfer2.get('idTransfer')
            if idTransfer1 > idTransfer2
              -1
            else
              if idTransfer1 < idTransfer2
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
      response.transfers

    data: ->
      result =
        limit: @limit
        offset: @offset
        searchText: @searchText
      if @isUseFilters
        result = $.extend result,
          dBegin: @filters.dBegin
          dEnd: @filters.dEnd
          accountsFrom: @filters.accountsFrom.toString()
          accountsTo: @filters.accountsTo.toString()
          tags: @filters.tags.toString()
      result

  # --------------------------------------------------------------------------------

  API =
    newTransferEntity: ->
      new Entities.Transfer
        dTransfer: App.request 'default:date'
        reportPeriod: App.request 'default:reportPeriod'
        idMoney: (App.request 'default:money')?.get('idMoney')
        isFee: false

    getTransferEntities: (options = {})->
      _.defaults options,
        force: false
      {force} = options

      if !App.entities.transfers
        App.entities.transfers = new Entities.Transfers
        force = true

      transfers = App.entities.transfers

      if force
        selected = transfers.getChosen()
        transfers.fetch
          reset: true
          success: ->
            transfers.chooseByIds selected

      transfers


  App.reqres.setHandler 'transfer:new:entity', ->
    API.newTransferEntity()

  App.reqres.setHandler 'transfer:entities', (options)->
    API.getTransferEntities(options)
