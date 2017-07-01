const fs = require('fs');
const chalk = require('chalk');
const semver = require('semver');

const usage = `Usage\n  npm run bump major|minor|patch\n`;
if (process.argv.length < 3) {
  return console.warn(chalk.red(usage));
}

const package = require('./package');
let script = fs.readFileSync('./bin/deploy', { encoding: 'utf8' });

const versionRegexp = /^VERSION=\d+\.\d+\.\d+$/m;
if (!script.match(versionRegexp)) {
  return console.warn(chalk.red(`Cannot find version line in bin/deploy\n`));
}

const releaseType = process.argv[process.argv.length - 1];
if ([ 'major', 'minor', 'patch' ].indexOf(releaseType) < 0) {
  return console.warn(chalk.red(`Unknown release type ${releaseType}\n\n${usage}`));
}

const newVersion = semver.inc(package.version, releaseType);
package.version = newVersion;
fs.writeFileSync('package.json', JSON.stringify(package, undefined, 2), { encoding: 'utf8' });

script = script.replace(versionRegexp, `VERSION=${newVersion}`);
fs.writeFileSync('bin/deploy', script, { encoding: 'utf8' });

console.log(chalk.green(newVersion));
console.log();
