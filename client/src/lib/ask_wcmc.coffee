class window.WcmcTipView
  constructor: ->
    tip = @pickATip()
    @renderTip(tip)

  pickATip: ->
    debugger
    WCMCTips[getRandomInt(0, WCMCTips.length-1)]

  renderTip: (tip) ->
    html = """
      <div id="wcmc-tip">
        <h1>#{tip[0]}</h1>
        <p>#{tip[1]}</p>
      </div>
    """
    $('body').append($(html))

WCMCTips = [
  ["Me", "Get back to work"]
  ["You", "Why this happened?"]
]

class window.WcmcTipController
  constructor: ->
    easter_egg = new Konami(=> @showAskWcmcButton())

  showAskWcmcButton: ->
    menuListEl = $('.menu .right ul')
    menuListEl.append("""
      <li id="ask-wcmc">
        <a href="#">Ask WCMC</a>
      </li>
    """)
    $('#ask-wcmc').on('click', (ev) =>
      ev.preventDefault()
      @showATip()
    )

  showATip: ->
    new WcmcTipView()

###
Returns a random number between min (inclusive) and max (exclusive)
###
getRandomArbitrary = (min, max) ->
  Math.random() * (max - min) + min

###
Returns a random integer between min (inclusive) and max (inclusive)
Using Math.round() will give you a non-uniform distribution!
###
getRandomInt = (min, max) ->
  Math.floor(Math.random() * (max - min + 1)) + min
