window.Controllers ||= {}

createSpinner = ->
  $('<img class="spinner" src="/images/spinner.gif">')

reflectSuccess = (el) ->
  $el = $(el)

  oldText = $el.text()
  $el.text("Done")

  $el.css('background-color', '#7BAB3C')
  $el.css('border-color', '#7BAB3C')
  $el.css('color', '#FFF')

  setTimeout(->
    $el.text(oldText)
    $el.removeAttr('style')
  , 1000)

reflectError = (el) ->
  $el = $(el)

  oldText = $el.text()
  $el.text("Error")

  $el.css('background-color', '#E37100')
  $el.css('border-color', '#E37100')
  $el.css('color', '#FFF')

  setTimeout(->
    $el.text(oldText)
    $el.removeAttr('style')
  , 1000)

reloadIndicatorTable = ->
  $.get("/partials/admin/indicators").success((indicatorTable) ->
    $("#indicator-table").replaceWith indicatorTable
  ).error((res) ->
    console.error "Error reloading indicators:"
    console.error res
  )

importIndicator = ->

  SubmitFormWithAjax(
    @
  ).success( ->
    console.log "Google Spreadsheet successfully imported"
    reloadIndicatorTable()
  ).error((xhr, status, err) ->
    console.log "Error importing google doc"
    err = xhr.responseJSON.error
    alert err
    throw new Error(err)
  )

showNewIndicatorForm = ->
  $.get("/partials/admin/indicators/new").success((data) ->
    table = $("#indicator-table")
    table.find("tbody").prepend data

    button = new SaveToDriveButton(
      table.find('.g-savetodrive')[0],
      "//#{document.domain}/assets/NRT GDoc Indicator Template.xlsx"
    )

    table.find(".submit-new-indicator").click(
      importIndicator.bind($("#new-indicator-form"))
    )
  ).error((err) ->
    console.log err
  )

updateAllIndicators = (ev) ->
  _.each($("#indicator-table .update"), (elem, idx) ->
      setTimeout(->
        $(elem).trigger "click"
      , idx * 1000)
  )

updateIndicatorData = (ev) ->
  id = ev.currentTarget.id

  spinnerEl = createSpinner()
  $(@).replaceWith(spinnerEl)

  $.ajax
    method: "POST"
    url: "/admin/updateIndicatorData/" + id
    success: (data) =>

      $(spinnerEl).replaceWith(@)
      reflectSuccess(@)

    error: (err) =>
      $(spinnerEl).replaceWith(@)
      reflectError(@)
      console.log "Message from remote server for #{id}: #{err.responseText}"

reloadIndicatorDefinition = (ev) ->
  spreadsheetKey = $(@).attr('data-spreadsheet-key')
  parentEl = $(@).parent()

  spinnerEl = createSpinner()
  $(@).replaceWith(spinnerEl)

  $.ajax
    method: "POST"
    url: "/indicators/import_gdoc"
    data: {spreadsheetKey: spreadsheetKey}
    success: =>
      reloadIndicatorTable().success(=>
        reflectSuccess($("[data-spreadsheet-key='#{spreadsheetKey}']"))
      ).error(=>
        $(spinnerEl).replaceWith(@)
        reflectError(@)
      )
    error: (err) =>
      $(spinnerEl).replaceWith(@)
      reflectError(@)
      console.log "Message from remote server for #{spreadsheetKey}: #{err.responseText}"

Controllers.Admin =
  start: ->
    $(".new-indicator").click showNewIndicatorForm

    $(".update-all").click updateAllIndicators

    $(".content").on("click", ".update", updateIndicatorData)

    $(".content").on("click", ".reload-definition", reloadIndicatorDefinition)
