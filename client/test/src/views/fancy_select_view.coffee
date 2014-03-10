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

test(".fancify() creates a UL with a fancy-select class after a select in the DOM", ->
  selectEl = $('<select data-behavior="fancy-select"></select>')
  $('body').append(selectEl)

  FancySelect.fancify()

  try
    nextEl = $(selectEl).next()
    assert.strictEqual(nextEl.prop("tagName"), "UL",
      "Expected a UL to be appended after the select box")
    assert.strictEqual(nextEl.attr('class'), "fancy-select",
      "Expected the UL to have the class 'fancy-select'")
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
    $listEl.remove()
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

  try
    assert.isTrue(
      itemSelectListener.calledOnce,
      "Expected itemSelectListener to be called once but was called
        #{itemSelectListener.callCount} times"
    )
  finally
    $('[data-behavior="fancy-select"]').remove()
    $listEl.remove()
)

test('.constructor appends the class attribute of the <select> element to the <ul>', ->
  selectEl = $('<select data-behavior="fancy-select" class="hats"></select>')
  $('body').append(selectEl)

  new FancySelect(selectEl)

  try
    $listEl = $(selectEl).next()
    classNames = $listEl.attr('class').split(" ")

    assert.lengthOf classNames, 2,
      "Expected both class attributes to be copied to the <ul>"

    assert.deepEqual classNames, ["fancy-select", "hats"]
  finally
    $('[data-behavior="fancy-select"]').remove()
    $listEl.remove()
)
