// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var _bolEdited = false;
var _bolSubmit = false;

$(function() {
  _init();
});

// This can be called multiple times per page load, as long at the jquery .each methods use the tagging logic (i.e. each one has a unique tag,
// the tag is checked before the processing happens, then the element is tagged as processed). This allows HTML to be inserted using AJAX, but
// still behave in the same manner as HTML that was there when the page loads. Current max id: #007.
function _init() {
  $('form').each(function() {
    if (_process_me(this, '#001')) {
      $(this).bind('submit', function() {
        _bolSubmit = true;
        $('.clear-default', $(this)).each(function() {
          if ($(this).val() == $(this).data('default')) $(this).val('');
        });
      });
      _tag_processed(this, '#001');
    }
  });

  $('*[data-remote]').each(function() {
    if (_process_me(this, '#007')) {
      $(this).bind('click', function() {
        _toggle_screen(true);
      });
      _tag_processed(this, '#007');
    }
  });

  $('.listener').each(function() {
    var objThis = $(this);
    if (objThis.data('event') && objThis.data('function') && window['_' + objThis.data('function')]) {
      $(objThis.data('target') || 'body').each(function() {
        if (_process_me(this, '#002')) {
          $(this).bind(objThis.data('event'), function(e) {
            window['_' + objThis.data('function')].call(objThis, e);
          });
          _tag_processed(this, '#002');
        }
      });
    }
  });

  $('.toggle').each(function() {
    if (_process_me(this, '#003')) {
      $(this).bind($(this).data('event'), function() {
        $($(this).data('target')).toggle();
        if ($(this).data('toggle-self')) $(this).toggle();
        return false;
      });
      _tag_processed(this, '#003');
    }
  });

  $('.editable').each(function() {
    if (_process_me(this, '#004')) {
      var objThis = $(this);

      // Change the _bolEdited to true whenever it is edited.
      objThis.bind('edited', function() { _bolEdited = true; });

      // Toggle the disabling for the in- and out- events.
      var strEventIn = (objThis.data('event') || '').toLowerCase().trim();
      var strEventOut = strEventIn;
      if (objThis.data('event-in')) strEventIn = objThis.data('event-in').toLowerCase().trim();
      if (objThis.data('event-out')) strEventOut = objThis.data('event-out').toLowerCase().trim();
      if ((strEventIn == strEventOut) && (strEventIn != '')) {
        $(this).bind($(this).data('event'), function() {
          if ($(this).hasClass('disabled')) {
            $(this).removeClass('disabled');
          } else {
            $(this).addClass('disabled');
          }
          return false;
        });
      } else {
        if (strEventIn != '') {
          $(this).bind(strEventIn, function() {
            $(this).removeClass('disabled');
            return false;
          });
        }
        if (strEventOut != '') {
          $(this).bind(strEventOut, function() {
            $(this).addClass('disabled');
            return false;
          });
        }
      }

      // Trigger the edited event when changes are made.
      objThis.bind('change', function() {
        $(this).trigger('edited');
      });
      objThis.bind('keypress', function() {
        $(this).trigger('edited');
      });

      // If the page loads with edited values (like in a refresh in FireFox), trigger the event.
      if (objThis.val() != objThis.attr('defaultValue')) $(this).trigger('edited');

      _tag_processed(this, '#004');
    }
  });

  $('.clear-default').each(function() {
    if (_process_me(this, '#005')) {
      if ($(this).data('default')) {
        $(this).bind('focus', function() {
          if ($(this).val() == $(this).data('default')) $(this).val('');
        });
        $(this).bind('blur', function() {
          if (($(this).val() == '') && ($(this).attr('defaultValue') != '')) $(this).val($(this).data('default'));
        });
      }
      _tag_processed(this, '#005');
    }
  });

  if (_process_me(window, '#006')) {
    $(window).bind('beforeunload', function() {
      if ((_bolEdited === true) && (_bolSubmit === false)) return _t['confirm_discard'];
    });
    _tag_processed(window, '#006');
  }

  _toggle_screen(false);
}

function _toggle_screen(bolShow) {
  var elScreen = $('#screen__');
  if (elScreen.length == 0) {
    $('body').append('<div id="screen__">&nbsp;</div>');
    elScreen = $('#screen__');
    elScreen.css({ opacity: 0.7 });
  }
  if (bolShow == undefined) {
    elScreen.toggle();
  } else if (bolShow) {
    elScreen.show();
  } else {
    elScreen.hide();
  }
}

// See if an element should be processed by the function indicated by the given tag.
function _process_me(elElement, strTag) {
  var bolResult = true;
  var arrProcessed = $(elElement).data('-processed');
  bolResult = (!(arrProcessed && (arrProcessed[strTag] === true)))
  return bolResult;
}

function _show(e) {
  $(this).show();
}

// Tag the element at processed by the function indicated by the given tag.
function _tag_processed(elElement, strTag) {
  elElement = $(elElement);
  var arrProcessed = elElement.data('-processed');
  if (!arrProcessed) arrProcessed = {};
  arrProcessed[strTag] = true;
  elElement.data('-processed', arrProcessed);
}
