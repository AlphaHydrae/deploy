const fs = require('fs');
const chalk = require('chalk');

const version = require('./package').version;
let script = fs.readFileSync('./bin/deploy', { encoding: 'utf8' });

const versionRegexp = /^VERSION=\d+\.\d+\.\d+$/m;
if (!script.match(versionRegexp)) {
  return console.warn(chalk.red(`Cannot find version line in bin/deploy\n`));
}

const versionBadgeRegexp = /^(\#\s*\[\!\[npm version\]\([^\)]+)\d+\.\d+\.\d+([^\)]+\)\]\([^\)]+\))$/m;
if (!script.match(versionBadgeRegexp)) {
  return console.warn(chalk.red(`Cannot find version badge line in bin/deploy\n`));
}

script = script.replace(versionRegexp, `VERSION=${version}`);
script = script.replace(versionBadgeRegexp, `$1${version}$2`)
fs.writeFileSync('bin/deploy', script, { encoding: 'utf8' });

console.log(chalk.green(`Version updated to ${version} in bin/deploy`));
console.log();
