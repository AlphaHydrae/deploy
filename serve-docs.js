const _ = require('lodash');

var env = {
  port: process.env.PORT,
  host: process.env.HOST,
  browser: process.env.BROWSER
};

var config = {};
try {
  config = require('./config');
} catch(e) {
  // Ignore missing or invalid config file
}

var defaults = {
  port: 4000,
  host: '127.0.0.1'
};

var fixed = {
  root: './docs',
  ignorePattern: /(deploy\.html|public)/
};

require('live-server').start(_.defaults(env, config, defaults, fixed));
