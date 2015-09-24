@CashFlow.module 'ImportApp.Show', (Show, App, Backbone, Marionette, $, _) ->
  class Show.Layout extends App.Views.Layout
    template: 'import/show/layout'
    className: 'container-fluid'

    ui:
      importSource: '[name=importSource]'
      importSourceType: '[name=importSourceType]'
      btnShowHelp: '[name=btnShowHelp]'
      help: '[name=help]'
      helpContent: '[name=helpContent]'
      fileName: '[name=fileName]'
      delimiter: '[name=delimiter]'
      isGroup: '[name=isGroup]'
      tag: '[name=tag]'
      note: '[name=note]'
      btnImport: '.btn[name=btnImport]'

      form: 'form'
      errorsLog: 'div[name=errorsLog]'
      warningsLog: 'div[name=warningsLog]'

      drebedengiAdditionalParameters: 'div[name=drebedengiAdditionalParameters]'
      isConvertDebts: '[name=isConvertDebts]'
      isConvertInvalidDebts: '[name=isConvertInvalidDebts]'


    form:
      focusFirstInput: true

    events:
      'click @ui.btnImport': 'import'
      'click @ui.btnShowHelp': 'showHelp'
      'change @ui.importSource': 'changeImportSource'
      'change @ui.importSourceType': 'changeImportSourceType'
      'change @ui.isConvertDebts': 'changeIsConvertDebts'

    changeIsConvertDebts: ->
      if @ui.isConvertDebts.prop('checked')
        @ui.isConvertInvalidDebts.amkEnable()
      else
        @ui.isConvertInvalidDebts.amkDisable()

    showHelp: (e) ->
      @ui.help.toggle()
      text = @ui.btnShowHelp.text()
      @ui.btnShowHelp.text(if text is 'Показать' then 'Скрыть' else 'Показать')
      e.preventDefault()

    changeImportSource: ->
      @ui.importSourceType.select2 'data', null

      @ui.importSourceType.empty()
      @ui.helpContent.html 'Выберите тип данных'
      idImportSource = @ui.importSource.select2('data')?.id
      if idImportSource
        html = '<option></option>'
        _.each App.entities.importSources.get(idImportSource).get('importSourceType'), (ist) ->
          html = html + "<option value='#{ist.code}'>#{ist.name}</option>"
        @ui.importSourceType.append(html)


    changeImportSourceType: ->
      code = @ui.importSourceType.select2('data')?.id || null
      if code
        importSources = App.entities.importSources.get(@ui.importSource.select2('data').id)
        help = (_.findWhere(importSources.get('importSourceType'),
            {code: parseInt(code)})).help || 'Извините, нет описания данного формата'
        @ui.helpContent.html(help)
        note = (_.findWhere(importSources.get('importSourceType'),
            {code: parseInt(code)})).note || ''
        @ui.note.html(note)
        delimiter = (_.findWhere(importSources.get('importSourceType'),
            {code: parseInt(code)})).delimiter || ';'
        @ui.delimiter.select2 'val', delimiter

        if importSources.id is 2 and +code is 2
          @ui.drebedengiAdditionalParameters.show()
        else
          @ui.drebedengiAdditionalParameters.hide()




    onRender: ->
      @ui.importSource.select2
        placeholder: ''

      @ui.importSource.on 'change', ->
        $(@).trigger 'blur'

      @ui.importSourceType.select2
        placeholder: ''
      #        data: =>
      #          idImportSource = @ui.importSource.select2('data')?.id
      #          if idImportSource
      #            results: _(App.entities.importSources.get(idImportSource).get('importSourceType')).map (ist) ->
      #              id: ist.code
      #              text: ist.name
      #          else
      #            results: {}
      @ui.importSourceType.on 'change', ->
        $(@).trigger 'blur'

      @ui.isGroup.prop('checked', false)

      @ui.delimiter.select2()

      #      @ui.file.filestyle
      #        buttonText: 'Выбрать'
      #        iconName: 'fa fa-folder-open'

      #      debugger
      #      @ui.file.fileupload
      #        dataType: 'json',
      #        url: 'http://localhost:3000/files'
      ##        add: (e, data) =>
      ##          data.context = @ui.btnImport.click ->
      ##            data.submit()
      ##          data.context = $('[name=btnImport]').text('Upload')
      ##          .appendTo(view)
      ##          .click ->
      ##            data.context = $('<p/>').text('Uploading...').replaceAll($(this))
      ##            data.submit()
      #
      #        done: (e, data) ->
      #          alert('Done')
      #          if(data && data.result)
      #            data.fileInput.context = []

      @ui.form.validate
#        ignore: ''
        rules:
          importSource:
            required: true
          importSourceType:
            required: true
          fileName:
            required: true
        messages:
          importSource:
            required: 'Пожалуйста, выберите источник данных'
          importSourceType:
            required: 'Пожалуйста, выберите тип данных'
          fileName:
            required: 'Пожалуйста, выберите файл для загрузки.'

      @$('form').submit (e) ->
        e.preventDefault()

    onShow: ->
      @uploader = new plupload.Uploader
        runtimes: 'html5,flash,silverlight,html4'
        browse_button: @$('[name=btnSelectFile]')[0]
        container: @$('[name=uploadFileContainer]')[0]
        multi_selection: false
        headers:
          'Authorization': App.session.authorization
        url: App.getServer() + '/files'
        filters: {
          mime_types: [
            {title: "Text files", extensions: "txt,csv"}
          ],
          max_file_size: "10mb",
        }
        init:
          FilesAdded: (up, files) =>
            # Remove early added files
            _.each _.difference(_.pluck(up.files, 'id'), _.pluck(files, 'id')), (idFile) ->
              up.removeFile(idFile)

            @ui.fileName.val files[0].name
            @ui.fileName.trigger 'blur'
#            _.each files, (file) ->
#              document.getElementById('filelist').innerHTML += '<div id="' + file.id + '">' + file.name + ' (' + plupload.formatSize(file.size) + ') <b></b></div>'

          Error: (up, err) =>
            NProgress.done()
            @addOpacityWrapper(false)

            @ui.fileName.val ''

            message = ''
            if err.response
              try
                response = JSON.parse err.response
                message = response.error.message
              catch e
                message = ''

            message = err.code + ": " + err.message unless message isnt ''
            showError message


          BeforeUpload: =>
            @addOpacityWrapper()
            NProgress.configure
              trickle: false

            NProgress.start()

          UploadProgress: (up) ->
            # на загрузку файла отводим 30%
            NProgress.set (up.total.percent / 100 * 0.3)

          UploadComplete: =>
            @ui.fileName.val ''

          FileUploaded: (up, file, res) =>
            response = JSON.parse res.response
            params =
              importSource: numToJSON @ui.importSource.select2('data').id
              importSourceType: numToJSON @ui.importSourceType.select2('data').id
              idFile: response.idFile
              delimiter: @ui.delimiter.val()
              isGroup: @ui.isGroup.prop('checked')
              tag: @ui.tag.val()

            if @ui.drebedengiAdditionalParameters.is(":visible")
              params = $.extend params,
                isConvertDebts: @ui.isConvertDebts.prop('checked')
                isConvertInvalidDebts: @ui.isConvertInvalidDebts.prop('checked')

            App.xhrRequest
              type: 'POST'
              url: 'import'
              data: JSON.stringify params
              success: (res, textStatus, jqXHR) =>
                @addOpacityWrapper(false)
                showInfo """
                  Импорт выполнен.
                  <br>
                  Загружено: #{res.loadedCount} строк.
                  <br>
                  Ошибок#{(if res.errorsCount > 0 then ': ' + res.errorsCount else ' нет')}
                  <br>
                  Предупреждений#{(if res.warningsCount > 0 then ': ' + res.warningsCount else ' нет')}
                """, true

                # show errors
                if res.errorsCount > 0
                  @ui.errorsLog.html(JST['backbone/apps/import/show/templates/_errors'](res.errors))
                else
                  @ui.errorsLog.empty()

                # show warnings
                if res.warningsCount > 0
                  @ui.warningsLog.html(JST['backbone/apps/import/show/templates/_warnings'](res.warnings))
                else
                  @ui.warningsLog.empty()

                # update references
                if res.references.moneys
                  App.entities.moneys.reset res.references.moneys

                if res.references.accounts
                  App.entities.accounts.reset res.references.accounts

                if res.references.contractors
                  App.entities.contractors.reset res.references.contractors

                if res.references.categories
                  App.entities.categories.reset res.references.categories

                if res.references.units
                  App.entities.units.reset res.references.units

                if res.references.tags
                  App.entities.tags.reset res.references.tags
              error: =>
                @addOpacityWrapper(false)

            # Give ~20 sec for import. Default trickleSpeed = 800 ms, so trickleRate = (100%-30%) / (20000ms/800ms) * 2 = 5.6%
            # коэффициент 2 делаем потому, что trickleRate коректируется random()
            NProgress.configure
              trickle: true
              trickleRate: 0.056
      #              trickleSpeed: 800


      @uploader.init()

    import: ->
      return if not @ui.form.valid()
      @uploader.start()


    onDestroy: ->
      @uploader.destroy()
      @ui.importSource.select2 'destroy'
      @ui.importSourceType.select2 'destroy'
      @ui.delimiter.select2 'destroy'
