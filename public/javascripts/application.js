// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function() {
  $('.toggle').each(function() {
    $(this).bind($(this).data('event'), function() {
      $($(this).data('target')).toggle();
      if ($(this).data('toggle-self')) $(this).toggle();
      return false;
    });
  });
});
