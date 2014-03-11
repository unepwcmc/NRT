class window.FancySelect extends Backbone.View
  template: Handlebars.templates['fancy_select.hbs']
  className: 'fancy-select'

  events:
    'click': 'setSelectionToClick'

  initialize: (options) ->
    @selectEl = options.selectEl
    @$selectEl = $(@selectEl)
    @$selectEl.hide()

    @render()

  selectOptions: ->
    optionEls = @$selectEl.find('option')

    return _.map(optionEls, (optionEl) =>
      $optionEl = $(optionEl)
      return {
        value: $optionEl.attr('value')
        text: $optionEl.text()
      }
    )

  selectedItemText: ->
    return @$selectEl.find('option:selected').text()

  render: ->
    selectClass = @$selectEl.attr('class')
    @$el.addClass(selectClass)

    @$el.html(@template(
      selectedItem: @selectedItemText()
      listItems: @selectOptions()
    ))

    @$selectEl.after(@$el)

    return @

  setSelectionToClick: (event) =>
    $itemEl = $(event.target)

    @$selectEl.val($itemEl.attr('value'))
    @$selectEl.trigger('change')

    @render()

  @fancify: (container)->
    selectEls = $(container).find('[data-behavior="fancy-select"]')

    _.each(selectEls, (selectEl) ->
      new FancySelect(selectEl: selectEl)
    )
