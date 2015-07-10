@CashFlow = do (Backbone, Marionette) ->
  App = new Marionette.Application

  #  App.session = {}

  # for IE9
  $.support.cors = true

  $doc = $(document)
  $doc.ajaxStart ->
    # Give 2 sec per request. Default trickleSpeed = 800 ms, so trickleRate = 100% / (2000ms/800ms) * 2 = 80%
    NProgress.configure
      trickle: true
      showSpinner: false
      trickleRate: 0.8

    NProgress.start()


  $doc.ajaxSend (e, xhr, options)->
    xhr.setRequestHeader('Authorization', App.session.authorization || '')


  $doc.ajaxComplete ->
    NProgress.done()


  $doc.ajaxError (event, jqxhr, settings, thrownError) ->
    NProgress.done()
    if jqxhr.responseJSON
      error = jqxhr.responseJSON.error
      message = error.message
      # coffeelint: disable=max_line_length
      #      message = (if message then message + '<br>' else '') + ('devMessage: ' + error.devMessage) if App.environment is 'development' and error.devMessage isnt ''
      message = (if message then message + '<br>' else '') + ('devMessage: ' + error.devMessage) if error.devMessage isnt '' and message is ''
      # coffeelint: enable=max_line_length

      if error.code is 'authorization_expired'
        callback = ->
          sessionStorage.clear()
          window.location.href = '/signin/'
        setTimeout callback, 2000


    else
      if thrownError isnt 'abort'
        message = thrownError
    #      if message is '' then message = 'Сервер недоступен. Повторите попытку позже.'
    showError message if message


  #  App.rootRoute = '/dashboard'
  App.rootRoute = '/cashflows/ies/details'

  # TODO Application Regions is deprecated. Use a Layout View
  App.addRegions
    headerRegion: '#header-region'
  #    menuRegion: '#menu-region'
    leftPanelRegion: '[name=left-panel-region]'
    mainRegion: '#main'


  App.on 'before:start', (options) ->
    #    App.entities ?= {}
    #    App.session ?= {}
    App.entities = {}
    App.environment = options.environment

    App.session =
      authorization: options.authorization

    body = $('body').addClass('fixed-navigation fixed-header fixed-ribbon')
    #body.disableSelection()
    # coffeelint: disable=max_line_length
    isMobile = (/iphone|ipad|ipod|android|blackberry|mini|windows\sce|palm/i.test(navigator.userAgent.toLowerCase()))
    # coffeelint: enable=max_line_length

    if not isMobile
      body.addClass 'desktop-detected'
    else
      body.addClass 'mobile-detected'

    $('#main').resize ->
      if $(window).width() < 979
        body
        .addClass 'mobile-view-activated'
        .removeClass 'minified'
      else
        if body.hasClass 'mobile-view-activated'
          body.removeClass 'mobile-view-activated'


  App.on 'start', ->
    App.entities.currencies = new CashFlow.Entities.Currencies
    App.entities.accountTypes = new CashFlow.Entities.AccountTypes
    App.entities.categoryPrototypes = new CashFlow.Entities.CategoryPrototypes
    App.entities.users = new CashFlow.Entities.Users
    App.entities.invitations = new CashFlow.Entities.Invitations
    App.entities.profile = new CashFlow.Entities.Profile
    App.entities.projects = new CashFlow.Entities.Projects
    App.entities.importSources = new App.Entities.ImportSources
    App.entities.currencyRateSources = new App.Entities.CurrencyRateSources

    App.entities.accounts = new CashFlow.Entities.Accounts
    App.entities.contractors = new CashFlow.Entities.Contractors
    App.entities.categories = new CashFlow.Entities.Categories
    App.entities.units = new CashFlow.Entities.Units
    App.entities.tags = new CashFlow.Entities.Tags
    App.entities.moneys = new CashFlow.Entities.Moneys

    App.xhrRequest
      url: 'entities'
      success: (res, textStatus, jqXHR) ->
        if res.messages
          if res.messages.welcome
            App.request 'message:show', 'Добро пожаловать!', res.messages.welcome
          else
            if res.messages.changeLog
              App.request 'message:show', 'История изменений', res.messages.changeLog

        App.entities.profile.set res.profile
        App.entities.projects.reset res.projects

        App.session.idProject = res.session.idProject

        App.entities.currencies.reset res.currencies
        App.entities.accountTypes.reset res.accountTypes
        App.entities.users.reset res.users
        App.entities.invitations.reset res.invitations
        App.entities.importSources.reset res.importSources
        App.entities.categoryPrototypes.reset res.categoryPrototypes
        App.entities.currencyRateSources.reset res.currencyRateSources

        App.entities.accounts.reset res.accounts
        App.entities.contractors.reset res.contractors
        App.entities.categories.reset res.categories
        App.entities.units.reset res.units
        App.entities.tags.reset res.tags
        App.entities.moneys.reset res.moneys

        App.params = res.params
        App.entities.badges = res.badges
        App.execute 'menu:set:badges'

        App.entities.dashboardBalances = new CashFlow.Entities.DashboardBalances
        App.entities.dashboardAccountsBalancesDaily =
          new CashFlow.Entities.DashboardAccountsBalancesDaily

        App.entities.reportDynamics = new CashFlow.Entities.ReportDynamics
        App.entities.reportDistribution = new CashFlow.Entities.ReportDistribution

        App.startHistory()

        if not App.getCurrentRoute()
          App.navigate App.rootRoute,
            trigger: true
            replace: true


        App.module('MenuApp').start()
        App.module('HeaderApp').start()

  #    .fail (jqxhr, textStatus, error) ->
  #      showError 'Ошибка запуска приложения: ' + textStatus + ", " + error


  App.reqres.setHandler 'default:region', ->
    App.mainRegion


  App.reqres.setHandler 'default:date', ->
    moment().format('YYYY-MM-DD')


  App.reqres.setHandler 'default:reportPeriod', ->
    moment().startOf('month').format('YYYY-MM-DD')

  # The first money  is the default currency
  App.reqres.setHandler 'default:money', ->
    # _.first ?
    App.entities.moneys.at(0)


  App.commands.setHandler 'use:project', (idProject) ->
    App.xhrAbortAll()
    App.xhrRequest
      type: 'PUT'
      url: "projects/#{idProject}/use"
      success: (res, textStatus, jqXHR) ->
        App.session.idProject = idProject
        App.vent.trigger 'change:active:project'

        App.entities.accounts.reset res.accounts
        App.entities.contractors.reset res.contractors
        App.entities.categories.reset res.categories
        App.entities.units.reset res.units
        App.entities.tags.reset res.tags
        App.entities.moneys.reset res.moneys

        App.params = res.params

        App.entities.badges = res.badges
        App.execute 'menu:set:badges'

        App.entities.dashboardAccountsBalancesDaily.resetParams()
        App.entities.reportDistribution.resetParams()
        App.entities.reportDynamics.resetParams()
        App.entities.ies?.resetFilters()
        App.entities.ieDetails?.resetFilters()
        App.entities.debt?.resetFilters()
        App.entities.exchanges?.resetFilters()
        App.entities.transfers?.resetFilters()


        if App.getCurrentRoute() is 'cashflows/ies/list'
          #          App.entities.ies.fetch
          #            reset: true
          App.CashFlowsIEsListApp.list()
        else
          App.entities.ies?.reset()

        if App.getCurrentRoute() is 'cashflows/ies/details'
          #          App.entities.ieDetails.fetch
          #            reset: true
          App.CashFlowsIEsDetailsApp.list()
        else
          App.entities.ieDetails?.reset()

        if App.getCurrentRoute() is 'cashflows/debts'
          #          App.entities.debts.fetch
          #            reset: true
          App.CashFlowsDebtsApp.list()
        else
          App.entities.debts?.reset()

        if App.getCurrentRoute() is 'cashflows/transfers'
          #          App.entities.transfers.fetch
          #            reset: true
          App.CashFlowsTransfersApp.list()
        else
          App.entities.transfers?.reset()

        if App.getCurrentRoute() is 'cashflows/exchanges'
          #          App.entities.exchanges.fetch
          #            reset: true
          App.CashFlowsExchangesApp.list()
        else
          App.entities.exchanges?.reset()

        if App.getCurrentRoute() is 'dashboard'
          #          App.entities.dashboardAccountsBalances.fetch()
          #          App.entities.dashboardAccountsBalancesDaily.fetch()
          App.DashboardApp.show()

        if App.getCurrentRoute() is 'reports/dynamics'
          #          App.entities.reportDynamics.fetch()
          App.ReportsDynamicsApp.show()

        if App.getCurrentRoute() is 'reports/distribution'
          #          App.entities.reportDistribution.fetch()
          App.ReportsDistributionApp.show()

        if App.getCurrentRoute() is 'plans'
          App.PlansApp.show()

  App

