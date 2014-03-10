suite("FancySelect")

test(".fancify() hides select boxes with data-behavior='fancy-select'", ->
  selectEl = $('<select data-behavior="fancy-select"></select>')
  $('body').append(selectEl)

  FancySelect.fancify()

  try
    assert.isFalse($(selectEl).is(':visible'),
      "Expected the select element to be hidden")
  finally
    $('[data-behavior="fancy-select"]').remove()
)

test(".fancify() creates a UL after a select in the DOM", ->
  selectEl = $('<select data-behavior="fancy-select"></select>')
  $('body').append(selectEl)

  FancySelect.fancify()

  try
    assert.strictEqual($(selectEl).next().prop("tagName"), "UL",
      "Expected a UL to be appended after the select box")
  finally
    $('[data-behavior="fancy-select"]').remove()
)

test(".constructor creates an <li> element for each <option>", ->
  selectEl = $("""
    <select data-behavior="fancy-select">
      <option>Pick me!</option>')
    </select>
  """)
  $('body').append(selectEl)

  new FancySelect(selectEl)

  try
    $listEl = $(selectEl).next()
    listItems = $listEl.find('li')

    assert.lengthOf listItems, 1,
      "Expected there to be one <li> element in the <ul>"

    assert.strictEqual $(listItems[0]).text(), "Pick me!"
  finally
    $('[data-behavior="fancy-select"]').remove()
)

test('Clicking on a list element triggers a change event for the select', ->
  selectEl = $("""
    <select data-behavior="fancy-select">
      <option>Pick me!</option>')
    </select>
  """)
  $('body').append(selectEl)

  new FancySelect(selectEl)

  itemSelectListener = sinon.spy()

  selectEl.on('change', itemSelectListener)

  $listEl = $(selectEl).next()
  listItem = $($listEl.find('li')[0])
  listItem.trigger('click')

  assert.isTrue(
    itemSelectListener.calledOnce,
    "Expected itemSelectListener to be called once but was called
      #{itemSelectListener.callCount} times"
  )
)
