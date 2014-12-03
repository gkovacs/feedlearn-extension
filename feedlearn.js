(function(){
  var root, insertBeforeItem, insertIfMissing, initialize;
  root = typeof exports != 'undefined' && exports !== null ? exports : this;
  insertBeforeItem = function(jfeeditem){
    return jfeeditem.before($('<iframe>').css({
      width: '495px',
      height: '300px'
    }).attr('src', 'https://feedlearn.herokuapp.com?facebook=true').attr('frameBorder', '0'));
  };
  root.numitems = 0;
  insertIfMissing = function(){
    var i$, ref$, len$, feeditem, jfeeditem, results$ = [];
    for (i$ = 0, len$ = (ref$ = $('.mbm')).length; i$ < len$; ++i$) {
      feeditem = ref$[i$];
      jfeeditem = $(feeditem);
      if (!jfeeditem.attr('feedlearninserted')) {
        jfeeditem.attr('feedlearninserted', true);
        root.numitems += 1;
        if (root.numitems % 10 === 5) {
          results$.push(insertBeforeItem(jfeeditem));
        }
      }
    }
    return results$;
  };
  initialize = function(){
    console.log('feedlearn loaded!');
    console.log('feedlearn2');
    return setInterval(function(){
      return insertIfMissing();
    }, 1000);
  };
  if (window.location.toString() === 'https://www.facebook.com/' && $('#feedlearn').length === 0) {
    $('html').append($('<div>').text('foobar').attr('id', 'feedlearn').css({
      position: 'absolute',
      top: '0px',
      left: '0px',
      zIndex: 1000
    }));
    console.log('insert occurred!');
    initialize();
  } else {
    console.log('skipping load!');
  }
}).call(this);
