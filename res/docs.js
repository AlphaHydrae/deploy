$(function() {
  // Make all external links open a new tab/window
  $('a').not('[href^="#"]').attr('target', '_blank');

  // Mark docco sections with a title for styling
  $('ul.sections li').not('#title').filter(function() {
    return $(this).find('.annotation h2').length;
  }).addClass('title title-2').end().filter(function() {
    return $(this).find('.annotation h3').length;
  }).addClass('title title-3');

  // Build a table of contents
  var toc = $('#toc');
  var tocSection = toc.closest('li');

  // Only include level 2 titles by default
  var mainTitles = tocSection.nextAll('li').find('h2');
  mainTitles.each(function() {
    var title = $(this);
    toc.append($('<li />').html($('<a />').attr('href', '#' + title.attr('id')).html(title.html())));
  });

  // Show the table of contents (it is hidden while not built)
  toc.css('display', 'block');
});
