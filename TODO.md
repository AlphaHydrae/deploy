# TODO

* standardize indented logs & log_color/echo_color
* also source environment-specific env files (e.g. `.env.production`)
* check required commands on server (at setup)
* add `-e|--environment` option to support environments named after a sub-command
* `setup` and `rev` should update the git clone url if it changed
* add `-q|--quiet` option (e.g. list releases)
* fix inheritance (no duplicates)
* add confirmation prompts
* verbosity (simple commands, full commands)
* command line options to add hooks (ensure they can be specified multiple times)
* npm-like Scripts (also usable as hooks)
* make configuration file optional
* support a symlink for the configuration file
* create a deployment log (include commit)
* add commands to manipulate previous releases (print info, rollback)
* add --path option to exec
* more detailed errors if setup has not been done
