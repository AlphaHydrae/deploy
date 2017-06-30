const fs = require('fs-extra');

const css = fs.readFileSync('tmp/docs/docco.css', { encoding: 'utf8' });
const customCss = fs.readFileSync('res/docs.css', { encoding: 'utf8' });
const js = fs.readFileSync('res/docs.js', { encoding: 'utf8' });
const jQuery = '<script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha256-k2WSCIexGzOj3Euiig+TlR8gA0EmPjuc79OEeY5L45g=" crossorigin="anonymous"></script>';

fs.mkdirsSync('docs');
fs.copySync('tmp/docs/public', 'docs/public');
fs.writeFileSync('docs/docco.css', `${css}\n${customCss}`, { encoding: 'utf8' });

let index = fs.readFileSync('tmp/docs/deploy.html', { encoding: 'utf8' });
index = index.replace(/<\/body>/, `${jQuery}<script>\n${js}</script></body>`);

fs.writeFileSync('docs/index.html', index, { encoding: 'utf8' });
