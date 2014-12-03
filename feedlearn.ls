root = exports ? this

insertBeforeItem = (jfeeditem) ->
  #jfeeditem.before $('<div>').text('newfoobar')
  jfeeditem.before $('<iframe>').css({
    width: '495px'
    height: '300px'
  }).attr('src', 'https://feedlearn.herokuapp.com?facebook=true').attr('frameBorder', '0')

root.numitems = 0

insertIfMissing = ->
  for feeditem in $('.mbm')
    jfeeditem = $(feeditem)
    if not jfeeditem.attr('feedlearninserted')
      jfeeditem.attr('feedlearninserted', true)
      root.numitems += 1
      if root.numitems % 10 == 5
        insertBeforeItem jfeeditem

initialize = ->
  console.log 'feedlearn loaded!'
  console.log 'feedlearn2'
  setInterval ->
    insertIfMissing()
  , 1000
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

if window.location.toString() == 'https://www.facebook.com/' and $('#feedlearn').length == 0
  $('html').append $('<div>').text('foobar').attr('id', 'feedlearn').css({
    position: 'absolute'
    top: '0px'
    left: '0px'
    z-index: 1000
  })
  console.log 'insert occurred!'
  initialize()
else
  console.log 'skipping load!'

#if root.feedlearn?
#  return
#root.feedlearn = 'feedlearn'

#setInterval ->
#  console.log 'interval going'
#, 2000

#sxl = root.sxl = ->
#  console.log 'hello world again!'


  
  

