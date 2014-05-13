window.SubmitFormWithAjax = (formElement) ->
  $formEl = $(formElement)

  $.ajax(
    type: $formEl.attr("method")
    url: $formEl.attr("action")
    data: $formEl.serialize()
  )