root = exports ? this

insertBeforeItem = (jfeeditem) ->
  #jfeeditem.before $('<div>').text('newfoobar')
  jfeeditem.before $('<iframe>').css({
    width: '495px'
    height: '300px'
  }).attr('src', 'https://feedlearn.herokuapp.com?facebook=true').attr('frameBorder', '0')

root.numitems = 0

insertIfMissing = ->
  for feeditem in $('.mbm._5jmm')
    jfeeditem = $(feeditem)
    if not jfeeditem.attr('feedlearninserted')
      jfeeditem.attr('feedlearninserted', true)
      root.numitems += 1
      if root.numitems % 10 == 5
        insertBeforeItem jfeeditem

root.mostrecentmousemove = Date.now()
root.timeopened = Date.now()

initialize = (format) ->
  if not (format == 'link' or format == 'interactive' or format == 'none')
    fburl = $('.fbxWelcomeBoxName').attr('href')
    fbname = $('.fbxWelcomeBoxName').text()
    chrome.runtime.send-message {feedlearn: 'missingformat', fburl: fburl, fbname: fbname}
  if format != 'none' #format == 'link' or format == 'interactive'
    setInterval ->
      insertIfMissing()
    , 1000
  $(document).mousemove ->
    root.mostrecentmousemove = Date.now()
  setInterval ->
    fburl = $('.fbxWelcomeBoxName').attr('href')
    fbname = $('.fbxWelcomeBoxName').text()
    timesincemousemove = Date.now() - root.mostrecentmousemove
    if timesincemousemove > 10000
      return
    chrome.runtime.send-message {feedlearn: 'fbstillopen', mostrecentmousemove: root.mostrecentmousemove, timeopened: root.timeopened, timesincemousemove: timesincemousemove, fburl: fburl, fbname: fbname}
  , 5000
  #for feeditem in $('.mbm')
  #  $(feeditem).before($('<div>').text('newfoobar'))
  #$.get 'https://geza.herokuapp.com/index.html', (data) ->
  #  console.log data
  /*
  $('html').append $('<iframe>').attr('src', 'https://karaoke.meteor.com/').css({
    position: 'absolute'
    top: '0px'
    left: '0px'
    width: '500px'
    height: '500px'
    z-index: 1000
  })
  window.addEventListener 'message', (event) ->
    if event.source != window
      return
    if not event.data.call?
      return
    console.log 'message posted!'
    console.log event.data
    eval(event.data.call)
  */
#console.log 'chrome!'
#console.log chrome
#console.log chrome.runtime
#console.log chrome.runtime.send-message

preinitialize = (format) ->
  if /*window.location.toString() == 'https://www.facebook.com/' and*/ $('#feedlearn').length == 0
    #console.log 'feedlearn loaded'
    #if $('.fbxWelcomeBoxName').attr('href')
    clearInterval root.firststartprocess
    $('html').append $('<div>').attr('id', 'feedlearn').css({
      position: 'absolute'
      display: 'none'
      top: '0px'
      left: '0px'
      z-index: 1000
    })
    initialize(format)

chrome.runtime.on-message.add-listener (request, sender) ->
  #console.log 'contentscript received message'
  #console.log request
  #console.log sender
  if request.feedlearn
    preinitialize(request.format)

loadfirststart = ->
  if /*window.location.toString() == 'https://www.facebook.com/' and*/ $('#feedlearn').length == 0
    fburl = $('.fbxWelcomeBoxName').attr('href')
    fbname = $('.fbxWelcomeBoxName').text()
    #console.log 'fburl:' + fburl
    #console.log 'fbname:' + fbname
    chrome.runtime.send-message {feedlearn: 'getformat', fburl: fburl, fbname: fbname}

loadfirststart()
root.firststartprocess = setInterval loadfirststart, 5000

#if root.feedlearn?
#  return
#root.feedlearn = 'feedlearn'

#setInterval ->
#  console.log 'interval going'
#, 2000

#sxl = root.sxl = ->
#  console.log 'hello world again!'


  
  

