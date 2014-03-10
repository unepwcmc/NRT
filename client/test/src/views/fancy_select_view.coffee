suite("FancySelect")

test(".fancify() hides select box children in the given DOM element", ->
  selectEl = $('<div><select data-behavior="fancy-select"></select></div>')
  $('body').append(selectEl)

  FancySelect.fancify(selectEl)

  assert.isTrue($(selectEl).is(':visible'),
    "Expected the select element to be hidden")
)

test(".fancify() creates a UL with a fancy-select class after a select in the DOM", ->
  container = $('<div><select data-behavior="fancy-select"></select></div>')

  FancySelect.fancify(container)

  nextEl = $(container).find('select').next()
  assert.strictEqual(nextEl.prop("tagName"), "UL",
    "Expected a UL to be appended after the select box")
  assert.strictEqual(nextEl.attr('class'), "fancy-select",
    "Expected the UL to have the class 'fancy-select'")
)

test(".constructor creates an <li> element for each <option>", ->
  optionValue = 'seductive-el'
  selectEl = $("""
    <select data-behavior="fancy-select">
      <option value="#{optionValue}">Pick me!</option>')
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

    assert.strictEqual $(listItems[0]).attr('value'), optionValue,
      "Expected the <li> to have the value of the option"

  finally
    $('[data-behavior="fancy-select"]').remove()
    $listEl.remove()
)

test('Clicking on a list element a changes the selected
value and triggers the change event', ->
  elemId = "seductive-element"
  selectEl = $("""
    <select data-behavior="fancy-select">
      <option value="bland-el">Boring</option>
      <option value="#{elemId}">Pick me!</option>
    </select>
  """)
  $('body').append(selectEl)

  new FancySelect(selectEl)

  itemSelectListener = sinon.spy()

  selectEl.on('change', itemSelectListener)

  $listEl = $(selectEl).next()
  listItem = $($listEl.find("li[value='#{elemId}']")[0])
  listItem.trigger('click')

  try
    assert.isTrue(
      itemSelectListener.calledOnce,
      "Expected itemSelectListener to be called once but was called
        #{itemSelectListener.callCount} times"
    )

    assert.strictEqual(
      selectEl.find("option:selected").attr('value'), elemId,
      "Expected the select to have the correct element selected"
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
