window.Controllers ||= {}

reloadIndicatorTable = ->
  $.get("/partials/admin/indicators").success((indicatorTable) ->
    $("#indicator-table").replaceWith indicatorTable
  ).error((res) ->
    console.error "Error reloading indicators:"
    console.error res
  )

importIndicator = (ev) ->
  ev.preventDefault()
  SubmitFormWithAjax(
    @
  ).success( ->
    console.log "Google Spreadsheet successfully imported"
    reloadIndicatorTable()
  ).error((res) ->
    console.log "Error importing google doc"
    alert "Unable to import google spreadsheet"
    throw new Error(res.responseText)
  )

showNewIndicatorForm = ->
  $.get("/partials/admin/indicators/new").success((data) ->
    table = $("#indicator-table")
    table.find("tbody").prepend data

    table.find("form").submit(importIndicator)
  ).error((err) ->
    console.log err
  )

Controllers.Admin =
  start: ->
    $(".new-indicator").click showNewIndicatorForm

