window.Controllers ||= {}

reloadIndicatorTable = ->
  $.get("/partials/admin/indicators").success((indicatorTable) ->
    $("#indicator-table").replaceWith indicatorTable
  ).error((res) ->
    console.error "Error reloading indicators:"
    console.error res
  )

importIndicator = () ->

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
  $.ajax
    method: "POST"
    url: "/admin/updateIndicatorData/" + id
    success: (data) ->
      $("##{id}.action-or-response").text "Success"
    error: (err) ->
      $("##{id}.action-or-response").text "Failed"
      console.log "Message from remote server for #{id}: #{err.responseText}"

createSpinner = ->
  $("""
    <img class="spinner" src="/images/spinner.gif">
  """)

reloadIndicatorDefinition = (ev) ->
  spreadsheetKey = $(this).attr('data-spreadsheet-key')
  parentEl = $(this).parent()

  $(this).before(createSpinner())
  $(this).remove()

  $.ajax
    method: "POST"
    url: "/indicators/import_gdoc"
    data: {spreadsheetKey: spreadsheetKey}
    success: reloadIndicatorTable
    error: (err) =>
      parentEl.text "Failed"
      console.log "Message from remote server for #{spreadsheetKey}: #{err.responseText}"

Controllers.Admin =
  start: ->
    $(".new-indicator").click showNewIndicatorForm

    $(".update-all").click updateAllIndicators

    $(".content").on("click", ".update", updateIndicatorData)

    $(".content").on("click", ".reload-definition", reloadIndicatorDefinition)
