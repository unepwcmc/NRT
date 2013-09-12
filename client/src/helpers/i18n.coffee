i18n.readyCallbacks = []
i18n.isReady = false

i18n.onReady = (callback) ->
  if i18n.isReady == true
    callback()
  else
    i18n.readyCallbacks.push(callback)

i18n.init(
  fallbackLng: 'en',
  resGetPath: '/locales/__lng__.json',
  cookieName: 'nrt_locale'
).done(() ->
  i18n.isReady = true

  for callback in i18n.readyCallbacks
    callback()
)
