class window.FancySelect
  constructor: (@selectEl) ->
    @$selectEl = $(@selectEl)
    @$listEl   = $('<ul class="fancy-select">')

    @$selectEl.hide()

    @copyAttributesToListEl()
    @insertListEl()
    @populateListEl()

  copyAttributesToListEl: ->
    selectClass = @$selectEl.attr('class')
    @$listEl.addClass(selectClass)

  insertListEl: ->
    @$selectEl.after(@$listEl)

  populateListEl: ->
    optionEls = @$selectEl.find('option')

    _.each(optionEls, (optionEl) =>
      $optionEl = $(optionEl)
      $listItemEl = $('<li>')
        .attr('value', $optionEl.attr('value'))
        .text($optionEl.text())

      @bindSetSelectionToClick($listItemEl, $optionEl)
      @$listEl.append($listItemEl)
    )

  bindSetSelectionToClick: ($listItemEl, $optionEl) ->
    $listItemEl.on('click', =>
      @$selectEl.val($optionEl.attr('value'))
      @$selectEl.trigger('change')
    )

  @fancify: (container)->
    selectEls = $(container).find('[data-behavior="fancy-select"]')

    _.each(selectEls, (selectEl) ->
      new FancySelect(selectEl)
    )
