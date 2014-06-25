exports.index = (req, res) ->
  find all themes

  find indicators for those themes where
    dpsir is correct for given filters
  and
    indicators have indicator data
  including
    the narrative recency
    the headline
    the description (from the user edited page)

  themes = [
    title: 'some theme'
    indicators: [
      page: {
        headline: {
          year: '2009',
           value: 1947,
           text: 'Bad',
           periodEnd: '31 Dec 2009'
        }
      }
      narrativeRecency: Up to date
      isUpToDate: true
      description:
      primary: true
      theme: 53a82180ee67d1684c000009
      dpsir: undefined
      indicatorDefinition: [object Object]
      shortName: Fish Landings
      name: Fish Landings
    ]
  ]

  dpsirFilter = paramsToBoolean(req.query?.dpsir)
  dpsirFilter = defaultDpsir if _.isEmpty(dpsirFilter)

  Theme.all().then((themes)->
    theThemes = themes.map((theme)->
      themePresenter = new ThemePresenter(theme)

      themePresenter.populateWithIndicatorWithData(
        dpsirFilter
      )
      themePresenter.populateDescription()

      theme.indicators = theme.indicators.map((indicator) ->
        indicatorPresenter = new IndicatorPresenter(indicator)
        indicatorPresenter.populateNarrativeRecency()
        indicatorPresenter.populateHeadline()
        indicatorPresenter.populateDescription()
        indicatorPresenter.populatedIndicator

      )
    )

    res.render "themes/index", themes: theThemes, dpsir: dpsirFilter
  ).catch((err)->
    console.error err
    console.error err.stack
    return res.send(500, "Error loading indicators")
  )
