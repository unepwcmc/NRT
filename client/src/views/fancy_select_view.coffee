class window.FancySelect
  constructor: (@selectEl) ->
    @$selectEl = $(@selectEl)
    @$listEl   = $('<ul>')

    @$selectEl.hide()

    @insertListEl()
    @populateListEl()

  insertListEl: ->
    @$selectEl.after(@$listEl)

  populateListEl: ->
    optionEls = @$selectEl.find('option')
    _.each(optionEls, (optionEl) =>
      listItemEl = $("<li>#{$(optionEl).text()}</li>")
      @bindClickHandler(listItemEl)
      @$listEl.append(listItemEl)
    )

  bindClickHandler: (element) ->
    element.on('click', =>
      @$selectEl.trigger('change')
    )

  @fancify: ->
    selectEls = $('[data-behavior="fancy-select"]')

    _.each(selectEls, (selectEl) ->
      new FancySelect(selectEl)
    )
