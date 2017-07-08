# deploy

<!-- DO NOT EDIT THIS FILE! This README is generated by running `npm run readme` -->

**_A (magic) shell script to deploy Git repositories_**

[![Build Status](https://travis-ci.org/AlphaHydrae/deploy.svg?branch=master)](https://travis-ci.org/AlphaHydrae/deploy)
[![npm version](https://img.shields.io/badge/version-2.0.3-blue.svg)](https://badge.fury.io/js/bash-deploy)
[![license](https://img.shields.io/npm/l/express.svg)](https://opensource.org/licenses/MIT)

Read the [annotated source](https://alphahydrae.github.io/deploy/)

Repository: [AlphaHydrae/deploy](https://github.com/AlphaHydrae/deploy) ([MIT Licensed](https://opensource.org/licenses/MIT))

Shamelessly inspired by: [visionmedia/deploy](https://github.com/visionmedia/deploy)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Usage](#usage)
- [Installation](#installation)
- [Requirements](#requirements)
- [Configuration file](#configuration-file)
  - [Single-value and multiple-value keys](#single-value-and-multiple-value-keys)
  - [Environment inheritance](#environment-inheritance)
- [Hooks](#hooks)
- [Configuration properties](#configuration-properties)
  - [Project](#project)
  - [SSH connection](#ssh-connection)
  - [Environment variables](#environment-variables)
- [General options](#general-options)
- [Sub-commands](#sub-commands)
  - [`<env> setup`](#env-setup)
  - [`<env> rev [-f|--force] [rev]`](#env-rev--f--force-rev)
  - [`[env] config [key]`](#env-config-key)
  - [`<env> config-all <key>`](#env-config-all-key)
  - [`[env] config-section`](#env-config-section)
  - [`<env> console [path]`](#env-console-path)
  - [`<env> exec <cmd>`](#env-exec-cmd)
  - [`<env> list`](#env-list)
  - [`update [--prefix dir] [--path path] [rev]`](#update---prefix-dir---path-path-rev)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Usage

**deploy** is a shell script to deploy your Git projects through SSH.
Add a `deploy.conf` file in your project's directory.
Here's an example for a Node.js project:

    # deploy.conf
    [production]
    repo  https://github.com/me/my-app
    host  my.server.com
    user  deploy
    path  /var/www/app
    # describe how to deploy your app
    env          NODE_ENV=production
    deploy       npm install --production
    post-deploy  npm start

**deploy** is language-agnostic.
For a Rails project, you could replace the last 3 lines with:

    env          RAILS_ENV=production
    deploy       bundle install --without development test
    deploy       rake assets:precompile
    post-deploy  rails server

Now run **deploy**!

```sh
deploy production setup
deploy production rev master
```

It will:
* Connect to `my.server.com` as the `deploy` user through SSH
* The `setup` command will set up a deployment structure and clone your repository
* The second `rev` command will checkout the latest version of your `master` branch and run the deployment hooks you defined (`deploy` and `post-deploy` in the configuration file)

Read on to learn what to write in the [configuration file](#configuration-file) or how to use each [sub-command](#sub-commands).

## Installation

With npm:

```sh
npm install -g bash-deploy
```

With curl:

```sh
FROM=https://raw.githubusercontent.com \
  && curl -sSLo /usr/local/bin/deploy \
  $FROM/AlphaHydrae/deploy/master/bin/deploy \
  && chmod +x /usr/local/bin/deploy
```

With wget:

```sh
FROM=https://raw.githubusercontent.com \
  && wget -qO /usr/local/bin/deploy \
  $FROM/AlphaHydrae/deploy/master/bin/deploy \
  && chmod +x /usr/local/bin/deploy
```

Or [download it](https://raw.githubusercontent.com/AlphaHydrae/deploy/master/bin/deploy) yourself.

## Requirements

**deploy** is a one-file bash script which requires the following commands: `cat`, `cut`, `date`, `git`, `grep`, `ls`, `mkdir`, `sed`, `ssh`, `tail` and `tar`.
Most bash shells have all of those out of the box except perhaps [Git](https://git-scm.com).

It also optionally requires the `chmod`, `cp` and `mktemp` commands to update itself.

## Configuration file

**deploy** reads its main configuration from a `deploy.conf` file in the current directory (this can be customized with [environment variables](#environment-variables) and [command line options](#general-options)).

The configuration file is basically a series of sections containing key/value pairs:

    # deploy.conf
    [staging]
    host  staging.example.com
    user  test
    # how to deploy
    post-deploy  ./run-test.sh

    [production]
    host 192.168.1.42
    user root
    # how to deploy
    env           NODE_ENV=production
    deploy        npm install --production
    deploy        npm run build
    post-deploy   pm2 start pm2.json

Each named section, delimited by `[name]`, represents an **environment** (i.e. a host machine) to deploy to,
in this example the *staging* and *production* environments.

Lines beginning with `#` are comments and are ignored.

Other lines are key/value pairs.
A key is a sequence of characters containing no whitespace, followed by at least one space.

For example, in the line `deploy npm run build`, the key is `deploy` and its value is `npm run build`.

### Single-value and multiple-value keys

Some keys like `repo`, `host`, `port` or `user` are simple configuration properties that have one value per environment.
If multiple values are found, the last one is used.

These keys can be overriden through an environment variable of the same name in uppercase and prefixed by `DEPLOY_`.
For example, the environment variable to override the `repo` key is `DEPLOY_REPO`.

Other keys like `setup`, `deploy` or `post-deploy` are multiple-value keys used for [hooks](#hooks).
They can be present multiple time in the same environment and all their values will be used in order.

### Environment inheritance

When deploying your project to multiple environments, there will probably be some configuration properties
that are identical for multiple environments.
To avoid repetition, an environment can **inherit** from one or multiple other environments:

    # deploy.conf
    [common]
    user dev
    deploy do-stuff
    deploy do-more-stuff

    [secure]
    user sekret
    deploy do-sensitive-stuff

    [production]
    inherits common
    inherits shared
    user root
    deploy just-do-it

In this example, the `production` environment inherits from `common` and `secure` (in that order).

The value of a *single-value* key like `user` will be the last value found in the environment inheritance tree.
In this case, it will be `root` for the `production` environment (the values inherited from the `common` and `secure` environments are overwritten).

A *multiple-value* key like `deploy` will include all values found in the entire inheritance tree.
In this case, it will have 4 values for the `production` environments, taken in order from the `common`, `secure` and `production` sections:

    do-stuff
    do-more-stuff
    do-sensitive-stuff
    just-do-it

For convenience in simple use cases, you can also add a **default environment** by including a nameless section in your configuration file:

    # deploy.conf
    []
    user dev
    deploy do-stuff
    deploy do-more-stuff

    [development]
    deploy do-it-somehow

    [production]
    user root
    deploy do-it-seriously

All environments that have no `inherits` key automatically inherit from the default environment.

## Hooks

Hooks are user-defined commands that can be run during a *deployment phase*.
There are currently two phases defined: **setup** and **deploy**.
The *setup* phase happens when you run the `setup` command,
while the *deploy* phase happens when you run the `rev` command.

There are various hooks for each phase: some that run before, some during and some after **deploy** does its thing.
These are the currently available hooks:

    pre-setup
    post-setup

    pre-deploy
    deploy
    post-deploy

Hooks are multiple-value keys that are optional and can be used as many times as you want.
They will all be run in order.

Each hook is run in a specific working directory and has access to various environment variables.
`$DEPLOY_PATH` is always exported and indicates the deployment directory
(which is not necessarily the same as the hook's working directory).
Additional user-defined variables may also be made available (see [environment variables](#environment-variables)).

Here's an example of how you could use hooks to cache your `node_modules` directory after every deployment
to shorten future installation times:

    # restore cache (if present)
    deploy       tar -xzf $DEPLOY_PATH/cache.gz -C . || exit 0
    # install new dependencies
    deploy       npm install --production
    # update cache
    post-deploy  tar -czf $DEPLOY_PATH/cache.gz node_modules

See the [`setup`](#setup) and [`rev`](#deploy) commands to learn exactly when and where hooks are executed.

## Configuration properties

### Project

* **`repo <url>`** (or the `$DEPLOY_REPO` variable) defines the Git URL from which your repository will be cloned at setup time.
* **`path <dir>`** (or the `$DEPLOY_PATH` variable) defines the directory into which your project will be deployed on the host.

### SSH connection

Various SSH options can be specified through the configuration file or environment variables:

* **`host <address>`** (or the `$DEPLOY_HOST` variable) is mandatory for all environments.
  It indicates which host or IP address to connect to.

* **`user <name>`** (or the `$DEPLOY_USER` variable) specifies the user to connect as.
  By default, you connect with the same name as your local user.

* **`identity <file>`** (or the `$DEPLOY_IDENTITY` variable) specifies a file from which the private key for public key authentication is read.

* **`forward-agent yes`** (or the `$DEPLOY_FORWARD_AGENT` variable) enables agent forwarding.

* **`port <number>`** (or the `$DEPLOY_PORT` variable) specifies the host port to connect to.

* **`tty yes`** (or the `$DEPLOY_TTY` variable) forces pseudo-terminal allocation.

All commands executed on the host through SSH will be logged to the console.

### Environment variables

You can define environment variables that will be exported on the host when executing hooks.

The `$DEPLOY_PATH` variable is always exported and indicates the deployment directory
configured by the user with the `path` config key or the local `$DEPLOY_PATH` variable.

* **`env <NAME>=<VALUE>...`** defines one or multiple environment variables to export on the host when running hooks.

      # deploy.conf
      env FOO=BAR
      env BAZ=QUX CORGE=GRAULT

* **`forward-env <NAME>...`** defines the name(s) of one or multiple local environment variables
  to export on the host when running hooks.

      # deploy.conf
      forward-env FOO
      forward-env BAR BAZ QUX

If you have a `.env` file in your local project directory, it will automatically be sourced.
This can be handy to create local variables that you can forward to the host.

    # .env
    export FOO=BAR
    export YEAR=$(date "+%Y")

## General options

These are the command line options of **deploy** itself, that are not specific to a particular sub-command.

They come directly after the `deploy` binary, before the environment and command:

```sh
deploy --version
deploy --config foo.conf production setup
```

Most of them have corresponding environment variables.

* **`--help`** prints usage information and exits.

* **`--version`** prints the current version and exits.

* **`--chdir <dir>`** (or the `$DEPLOY_CHDIR` variable) changes **deploy**'s working directory before loading the configuration file.

* **`--config <path>`** (or the `$DEPLOY_CONFIG` variable) allows you to set a custom path for the configuration file (defaults to `./deploy.conf`).

* **`--color always|never|auto`** (or the `$DEPLOY_COLOR` variable) enables/disables colors in the output of the script

  This defaults to `auto`, which only enables colors if the current terminal is interactive.

## Sub-commands

These are the commands you will use to set up and deploy your projects.

Note that most (but not all) of **deploy**'s sub-commands require an environment to be specified before the actual command name, for example:

```sh
deploy setup             # error! no environment
deploy production setup  # all good
```

<a name="setup"></a>

### `<env> setup`

Perform **first-time setup** tasks on the host before deployment.
You should only have to run this once before deploying the first time.

```sh
deploy production setup
```

**deploy** will create the following structure for you in the deployment directory defined by the `path` config key (or the `$DEPLOY_PATH` variable):
* `$DEPLOY_PATH/releases` will contain each deployment's files
* `$DEPLOY_PATH/repo` will be a bare clone of your Git repository
* `$DEPLOY_PATH/tmp` will be used to store temporary files during deployment

This phase has 3 hooks that are all executed in the deployment directory.
Note that this directory **must already exist** on the host and be writable by the user you connect as.

This is what **deploy** will do during setup:

* Run user-defined `pre-setup` hooks (if any).

* Create the `releases` and a `tmp` directories if they don't exist already.

* Clone the repository into the `repo` directory if it isn't already there.

* Run user-defined `post-setup` hooks (if any).

<a name="deploy"></a>

### `<env> rev [-f|--force] [rev]`

**Deploy a new release** from the latest changes in the Git repository.

For each deployment, a new release directory will be created in `releases` in the deployment directory.
The name of a release directory is the current date and time in the `YYYY-MM-DD-HH-MM-SS` format.
(You can list deployed releases with the [list command](#list).)

You must provide a Git revision, i.e. a **commit, branch or tag** to deploy,
either as the `[rev]` argument, with the `rev` config key or the `$DEPLOY_REV` variable.

If your Git repository is **private**, make sure that the deployment user has access to it.

Note that **deploy** will refuse to deploy unless all your local changes are committed and pushed.
You can override this behavior with the `-f|--force` option (or the `$DEPLOY_FORCE` variable).

This is what **deploy** will do during deployment:

* Run user-defined pre-deploy hooks (if any) in the directory of the **previous release**.
  You may define **pre-deploy hooks** to perform any task you might want to do before the actual deployment
  (e.g. you might want to stop the currently running version or put it into maintenance mode).

* Fetch the latest changes from the repository.

* Create the new release directory and extract the source at the specified revision into it.

* Run user-defined deploy hooks (if any) in the new release directory.
  You should define **deploy hooks** to build your application or install its dependencies at this stage.

* Make a symlink of the new release directory as `current` in the deployment directory.

* Run user-defined post-deploy hooks (if any) in the current release directory
  (which is now the same as the new release directory that was just created).

  You should define **post-deploy hooks** to execute or start your application at this stage.

### `[env] config [key]`

Print values from your `deploy.conf` configuration file.

* If called with **no environment and no argument**, it prints the whole configuration file:

  ```sh
  $> deploy config
  []
  user dev

  [production]
  user root
  port 222
  ```

* If called with **the environment and a key**, it prints the last value of that key for that environment
  (only the last value is printed even for a multiple-value key):

  ```sh
  $> deploy production config user
  root
  ```

  Exits with status 1 if no value is found for the key.

### `<env> config-all <key>`

Print all values of a config key in the current environment and its inherited environments
(all values are printed even for a single-value key):

```sh
$> deploy production config-all user
dev
root
```

Exits with status 1 if no value is found for the key.

### `[env] config-section`

Print all values of a config section "as is" (with no inheritance).
If no environment is specified, the default config section is printed.

Exits with status 1 if the config section is not found (including the default one).

### `<env> console [path]`

Launch an interactive **ssh session** on the host.

* If an **absolute path** is specified, the session starts there.

  ```sh
  deploy production console /var/www
  ```

* If **no path** is specified, the session starts in the deployment directory.

  ```sh
  deploy production console
  ```

* If a **relative path** is specified, it starts there relative to the deployment directory.

  ```sh
  deploy production console current
  ```

### `<env> exec <cmd>`

**Execute** the specified command on the host.

```sh
deploy production exec ps -ef
```

<a name="list"></a>

### `<env> list`

List the **releases** that have been deployed on the host.

```sh
$> deploy production list
2016-12-24-17-45-23
2017-01-01-02-03-43
2017-04-01-00-00-00
```

### `update [--prefix dir] [--path path] [rev]`

Updates **deploy** to the latest version by downloading it from the Git repository and installing it at `/usr/local/bin/deploy` (by default).

In addition to the basic requirements, this sub-command also requires `chmod`, `cp` and `mktemp` to be available in the shell.

* If a **`--prefix <dir>`** directory is specified, the script will be installed
  at `bin/deploy` relative to that directory.

* If a **`--path <file>`** file is specified, the script will be installed there
  (this *ignores* the `--prefix` option).

* The optional **`[rev]`** argument is the Git revision at which to install the script.
  This defaults to `master`.

The installation path must be a writable file or not exist.
If the installation path does not already exist, its parent must be a writable directory.

To perform the update, **deploy** will download its Git repository into a temporary directory that will be cleaned up when the update is done (or fails).

The correct revision of the script is then copied to the installation path and made executable.
