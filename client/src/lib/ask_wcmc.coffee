class window.WcmcTipView
  constructor: ->
    tip = @pickATip()
    @renderTip(tip)

  pickATip: ->
    WCMCTips[getRandomInt(0, WCMCTips.length-1)]

  renderTip: (tip) ->
    html = $("""
      <div id="wcmc-tip">
        <div class="strip">
          <img src="/images/staff/#{tip[0]}.jpg"/>
          <p>#{tip[1]}</p>
        </div>
        <a class="button close">Close</a>
      </div>
    """)
    $('body').append(html)
    html.find('.close').on('click', @removeView)

  removeView: ->
    $('#wcmc-tip').remove()


WCMCTips = [
  ["james", "Get back to work"]
  ["james", "Why this happened?"]
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
