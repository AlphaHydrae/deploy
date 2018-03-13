# TODO

* parse options & arguments in all commands (to avoid ignoring unknown stuff)
* do not run pre-deploy hooks for first deployment
* check required commands on server (at setup)
* check required variables for all commands (e.g. `path`)
* add `-e|--environment` option to support environments named after a sub-command
* `setup` and `rev` should update the git clone url if it changed
* fix inheritance (no duplicates)
* add confirmation prompts
* verbosity (simple commands, full commands)
* command line options to add hooks
* npm-like Scripts (also usable as hooks)
* make configuration file optional
* support a symlink for the configuration file
* create a deployment log (include commit)
* add commands to manipulate previous releases (print info, rollback)
* add --path option to exec
