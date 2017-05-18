# Deploy

Deployment shell script.

Inspired by [visionmedia/deploy][visionmedia].

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Directives](#directives)
  - [key (optional)](#key-optional)
  - [ref (optional)](#ref-optional)
  - [user](#user)
  - [host](#host)
  - [port (optional)](#port-optional)
  - [repo](#repo)
  - [path](#path)
  - [env](#env)
  - [forward-agent](#forward-agent)
  - [needs_tty](#needs_tty)
- [Hooks](#hooks)
  - [pre-setup](#pre-setup)
  - [post-setup](#post-setup)
  - [pre-deploy](#pre-deploy)
  - [deploy](#deploy)
  - [post-deploy](#post-deploy)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installation

    $> git clone https://github.com/AlphaHydrae/deploy.git
    $> cd deploy
    $> make install

Or:

    $> curl -sSLo /usr/local/bin/deploy \
       https://raw.githubusercontent.com/AlphaHydrae/deploy/master/bin/deploy \
       && chmod +x /usr/local/bin/deploy

## Usage

    Usage: deploy [options] <env> [command]

    Options:

      -C, --chdir <path>   change the working directory to <path>
      -c, --config <path>  set config path. defaults to ./deploy.conf
      -V, --version        output program version
      -h, --help           output help information

    Commands:

      setup                run remote setup commands
      update [ref]         deploy a release (commit, branch or tag)
      config [key]         output config file or [key]
      exec <cmd>           execute the given <cmd>
      console              open an ssh session to the host
      list                 list previous deploy commits

    Examples:

      deploy prod setup             run remote setup in the prod env
      deploy dev ref master         deploy the master branch in the dev env
      deploy prod exec pm2 status   run 'pm2 status' in the prod env

## Configuration

 By default `deploy` will look for _./deploy.conf_, consisting of one or more environments, `[staging]`, `[production]`, etc, followed by directives.

    [production]
    key /path/to/key.pem
    user deployer
    host n.n.n.n
    port nn
    repo git@github.com:someone/something.git
    path /var/www/something.com
    ref master
    post-deploy /var/www/something.com/update.sh

## Directives

### key (optional)

Path to identity file used by `ssh -i`.

    key /path/to/some.pem

### ref (optional)

When specified, that commit, branch or tag is checked out.

    ref develop

### user

User for deployment.

    user deployer

### host

Server hostname.

    host 50.17.255.50

### port (optional)

Server port.

    port 22

### repo

Git repository to clone.

    repo git@github.com:someone/something.git

### path

Deployment path.

    path /var/www/something.com

### env

Additional environment variables that will be available in hooks.
This directive can be used multiple times and each one can declare multiple variables.

    env FOO=bar BAR=baz
    env PATH=/cool/bin:$PATH

### forward-agent

Webhosts normally use read-only deploy keys to access private git repositories.
If you'd rather use the credentials of the person invoking the deploy
command, put `forward-agent yes` in the relevant config sections.
Now the deploy script will invoke `ssh -A` when deploying and there's
no need to keep SSH keys on your servers.

### needs_tty

If your deployment scripts require any user interaction (which they shouldn't, but
often do) you'll probably want SSH to allocate a tty for you. Put `needs_tty yes`
in the config section if you'd like the deploy script to invoke `ssh -t` and ensure
you have a tty available.

## Hooks

All hooks are arbitrary commands executed during the deployment process.
Each hook may be specified multiple times.

The `$ROOT_DIR` variable is always available to hooks and contains the deployment path.

### pre-setup

Executed before setup in the deployment path.

    pre-setup echo Ready

### post-setup

Executed after setup in the deployment path.

    post-setup mkdir $ROOT_DIR/cache

### pre-deploy

Executed before deployment in the current release directory (which still points to the previous release).

    pre-deploy ./bin/something

### deploy

Executed during deployment when all that remains is to symlink the new release directory as the current release.

    deploy npm install --production

### post-deploy

Executed after deployment once the new release directory has been symlinked as the current release.

    post-deploy ./bin/restart

[visionmedia]: https://github.com/visionmedia/deploy
