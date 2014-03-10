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
      listItemEl = $("<li value='#{$optionEl.attr('value')}'>#{$optionEl.text()}</li>")
      @bindClickHandler(listItemEl)
      @$listEl.append(listItemEl)
    )

  bindClickHandler: (element) ->
    element.on('click', =>
      @$selectEl.trigger('change')
    )

  @fancify: (container)->
    selectEls = $(container).find('[data-behavior="fancy-select"]')

    _.each(selectEls, (selectEl) ->
      new FancySelect(selectEl)
    )
