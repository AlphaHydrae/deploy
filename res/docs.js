$(function() {
  $('ul.sections li').not('#title').filter(function() {
    return $(this).find('.annotation h2, .annotation h3').length;
  }).addClass('title');
});
