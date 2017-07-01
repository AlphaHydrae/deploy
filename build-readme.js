const _ = require('lodash');
const fs = require('fs');

const header = fs.readFileSync('res/HEADER.md', { encoding: 'utf8' });
const source = fs.readFileSync('bin/deploy', { encoding: 'utf8' });
let lines = source.split("\n");

// Remove hashbang line
lines = lines.slice(1);

// Replace blank lines and source lines by empty lines
lines = _.map(lines, line => !line.trim().length || !line.match(/^\s*#/) ? '' : line);

// Remove comment markers and leading whitespace
lines = _.map(lines, line => line.replace(/^\s*# ?/, ''));

let ignore = false;
lines = _.reduce(lines, (memo, line, i) => {
  // Collapse successive blank lines to one blank line
  if (i >= 1 && !memo[memo.length - 1].trim().length && !line.trim().length) {
    return memo;
  } else if (!ignore && line.match(/<!--\s+annotated-source-only\s+-->/)) {
    ignore = true;
    return memo;
  } else if (ignore && line.match(/<!--\s+annotated-source-only-end\s+-->/)) {
    ignore = false;
    return memo;
  } else if (ignore) {
    return memo;
  }

  memo.push(line);
  return memo;
}, []);

// Replace the toc <ul> by a doctoc marker
const tocLine = _.find(lines, line => line.match(/<ul\s+id="toc"[^>]*>[^<]*<\/ul>/i));
lines.splice(lines.indexOf(tocLine), 1, '<!-- START doctoc -->', '<!-- END doctoc -->');

const readme = header + lines.join("\n");

// Dump the result
fs.writeFileSync('README.md', readme, { encoding: 'utf8' });
