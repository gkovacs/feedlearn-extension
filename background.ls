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
  chrome.cookies.getAll {url: 'https://feedlearn.herokuapp.com/'}, (cookie) ->
    output = {}
    for x in cookie
      name = unescape x.name
      value = unescape x.value
      output[name] = value
    callback output

get-remote-cookies = (username, callback) ->
  if not username? or username == 'Anonymous User' or username.length == 0
    return
  $.getJSON ('https://feedlearn.herokuapp.com/cookiesforuser?' + $.param({username: username})), (cookies) ->
    #console.log 'remote cookies:'
    #console.log cookies
    for k,v of cookies
      chrome.cookies.set({url: 'https://feedlearn.herokuapp.com/', name: k, value: v.toString(), path: '/'})
    callback(cookies)

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
  if request? and request.feedlearn == 'missingformat'
    fbname = request.fbname
    fburl = request.fburl
    get-cookie (cookie) ->
      fullname = cookie.fullname
      if not fullname? or fullname == 'Anonymous User' or fullname.length == 0
        cookie.fullname = fbname
      addlog {type: 'missingformat', fbname: fbname, fburl: fburl}, cookie
  if request? and request.feedlearn == 'fbstillopen'
    get-cookie (cookie) ->
      addlogfb {type: 'fbstillopen', mostrecentmousemove: request.mostrecentmousemove, timeopened: request.timeopened, timesincemousemove: request.timesincemousemove}, cookie
  if request? and request.feedlearn == 'getformat'
    #console.log 'right type'
    #send-response({value: 'hello'})
    #chrome.cookies.get {url: 'http://feedlearn.herokuapp.com/', name: 'format'}, (cookie) ->
    fbname = request.fbname
    fburl = request.fburl
    get-cookie (cookie) ->
      fullname = cookie.fullname
      if not fullname? or fullname == 'Anonymous User' or fullname.length == 0
        fullname = request.fbname
        cookie.fullname = fullname
        addlog {type: 'missingcookie', fbname: fbname, fburl: fburl}, cookie
      get-remote-cookies fullname, (remotecookie) ->
        for k,v of remotecookie
          cookie[k] = v
        #console.log 'combined cookie:'
        #console.log cookie
        #console.log cookie.value
        format = cookie.format
        send-response {feedlearn: true, format: format}
        chrome.tabs.query {}, (tabs) ->
          for tab in tabs
            chrome.tabs.send-message tab.id, {feedlearn: true, format: cookie.format}
        addlog {type: 'fbvisit', fbname: fbname, fburl: fburl}, cookie
        addlogfb {type: 'fbvisit', fbname: fbname, fburl: fburl}, cookie
        #setInterval ->
        #  addlogfb {type: 'fbstillopen'}, cookie
        #, 5000
