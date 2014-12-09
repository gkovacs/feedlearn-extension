chrome.runtime.on-message.add-listener (request, sender, send-response) ->
  console.log 'message'
  if request? and request.feedlearn == 'getformat'
    console.log 'right type'
    #send-response({value: 'hello'})
    chrome.cookies.get {url: 'http://feedlearn.herokuapp.com/', name: 'format'}, (cookie) ->
      console.log 'got cookies'
      console.log cookie.value
      send-response {feedlearn: true, format: cookie.value}
      chrome.tabs.query {}, (tabs) ->
        for tab in tabs
          chrome.tabs.send-message tab.id, {feedlearn: true, format: cookie.value}
      return true
