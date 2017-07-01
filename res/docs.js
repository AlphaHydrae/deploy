$(function() {
  // Make all external links open a new tab/window
  $('a').not('[href^="#"]').attr('target', '_blank');

  // Mark docco sections with a title for styling
  $('ul.sections > li').not('#title').filter(function() {
    return $(this).find('.annotation h2').length;
  }).addClass('title title-2').end().filter(function() {
    return $(this).find('.annotation h3').length;
  }).addClass('title title-3');

  // Build a table of contents
  var toc = $('#toc');
  var tocSection = toc.closest('li');

  // Only include level 2 titles by default
  var mainTitles = tocSection.nextAll('li').find('h2');
  mainTitles.each(function(i) {

    var title = $(this);

    var tocLine = $('<li />').html($('<a />').attr('href', '#' + title.attr('id')).html(title.html()));
    toc.append(tocLine);

    var sections = $('ul.sections > li');
    var start = sections.index(title.closest('li')) + 1;
    var end;

    var nextTitle = mainTitles[i + 1];
    if (nextTitle) {
      end = sections.index(nextTitle.closest('li'));
    }

    var subTitles = sections.slice(start, end).filter('.title-3').find('.annotation h3');
    if (subTitles.length) {

      var subToc = $('<ul />');
      subTitles.each(function(i) {

        var subTitle = $(this);

        var titleText = subTitle.text();
        titleText = titleText.replace(/(<[^<>]+>|\[[^\[\]]+\])/g, '').trim();

        subToc.append($('<li />').append($('<a />').attr('href', '#' + subTitle.attr('id')).text(titleText)));
      });

      tocLine.append(subToc);
    }
  });

  // Show the table of contents (it is hidden while not built)
  toc.css('display', 'block');
});
