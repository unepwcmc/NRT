assert = chai.assert

suite('DPSIR Filter View')

test('.getParameters correctly reads the selected DPSIR elements', ->
  el = $('<ul>
    <li class="active">D</li>
    <li>P</li>
  </ul>')[0]

  view = new Backbone.Views.DpsirFilterView(el: el)

  parameters = view.getParameters()

  expectedParameters =
    driver: true
    pressure: false
  assert.deepEqual parameters, expectedParameters
)

test('.updateParams updates the parameters based on the given event', ->
  $el = $('<ul>
    <li class="active">D</li>
    <li>P</li>
  </ul>')

  event = target: $el.find('li.active')[0]

  view = new Backbone.Views.DpsirFilterView(el: $el[0])

  expectedParameters =
    driver: false
    pressure: false

  parameters = view.updateParams(event)

  assert.deepEqual(parameters, expectedParameters)
)
