root = exports ? this

post-json-ext = (url, jsondata, callback) ->
  $.ajax {
    type: 'POST'
    url: url
    data: JSON.stringify(jsondata)
    success: (data) ->
      if callback?
        callback data
      #else
      #  console.log data
    contentType: 'application/json'
    #dataType: 'json'
  }

get-cookie = (callback) ->
  chrome.cookies.getAll {url: 'http://feedlearn.herokuapp.com/'}, (cookie) ->
    output = {}
    for x in cookie
      name = unescape x.name
      value = unescape x.value
      output[name] = value
    callback output

#root.isfirst = true
#root.starttime = Date.now()

addlogfb = (logdata, cookie) ->
  data = $.extend {}, logdata
  data.username = cookie.fullname
  data.lang = cookie.lang
  data.format = cookie.format
  data.scriptformat = cookie.scriptformat
  data.time = Date.now()
  data.timeloc = new Date().toString()
  #data.starttime = root.starttime
  post-json-ext 'https://feedlearn.herokuapp.com/addlogfb', data

addlog = (logdata, cookie) ->
  data = $.extend {}, logdata
  data.username = cookie.fullname
  data.lang = cookie.lang
  data.format = cookie.format
  data.scriptformat = cookie.scriptformat
  data.time = Date.now()
  data.timeloc = new Date().toString()
  #data.starttime = root.starttime
  post-json-ext 'https://feedlearn.herokuapp.com/addlog', data

chrome.runtime.on-message.add-listener (request, sender, send-response) ->
  if request? and request.feedlearn == 'fbstillopen'
    get-cookie (cookie) ->
      addlogfb {type: 'fbstillopen', mostrecentmousemove: request.mostrecentmousemove, timeopened: request.timeopened, timesincemousemove: request.timesincemousemove}, cookie
  if request? and request.feedlearn == 'getformat'
    #console.log 'right type'
    #send-response({value: 'hello'})
    #chrome.cookies.get {url: 'http://feedlearn.herokuapp.com/', name: 'format'}, (cookie) ->
    get-cookie (cookie) ->
      #console.log 'got cookies'
      #console.log cookie.value
      format = cookie.format
      send-response {feedlearn: true, format: format}
      chrome.tabs.query {}, (tabs) ->
        for tab in tabs
          chrome.tabs.send-message tab.id, {feedlearn: true, format: cookie.value}
      addlog {type: 'fbvisit'}, cookie
      addlogfb {type: 'fbvisit'}, cookie
      #setInterval ->
      #  addlogfb {type: 'fbstillopen'}, cookie
      #, 5000
