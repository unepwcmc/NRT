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
  ["adam", "You probably have to many gears"]
  ["agnieszka", "Limit your work in progress!"]
  ["andrea", "cat-falls-down-stairs.gif"]
  ["blanca", "Surfaces and edges provide visual clues which are grounded in reality"]
  ["craig", "Do what you want, I'm leaving"]
  ["decio", "That pie-chart should probably be 3D"]
  ["james", "No tips, just a sincere for being such a wonderful team to work with. Best of luck for the future"]
  ["miguel", "It's probably a projection issue"]
  ["simao", "Got, Got, Need, Got..."]
  ["stuart", "<i>Quietly gets on with his work</i>"]
  ["tim", "Have you tried nextifying your brand proposition?"]
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
