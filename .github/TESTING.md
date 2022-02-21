# Testing doil

Before a release doil needs to be tested deeply. For that we implemented a mandatory test protocoll which will additionally check all the functions of doil from a user perspective.

## Release Test Protocoll

### Creating a new instance

* [x] Instance can be created
* [x] Instance can be created with specific target directory
* [x] All states will be applied correctly
* [x] Combination: ILIAS 7 + PHP 7.3 works
* [ ] Combination: ILIAS 8 + PHP 8.0 works
* [ ] ilServer works (certificates can be shown)
* [ ] Cron works (checked in ILIAS backend)
* [x] Optional: Autoinstaller works for ILIAS 7+

### Import / Export

* [x] An instance can be exported into ZIP file
* [x] retrieved ZIP file can be imported into an existing instance
* [x] retrieved ZIP file can be imported into a new instance

### Manage an existing instance

* [x] Instance can be started
* [x] Instance is reachable from the browser
* [x] It is possible to login via cli
* [x] Instance contains the data when left
* [x] Instance can be stopped
* [x] A state can be applied
* [x] Instance can be deleted
* [x] The active directory can be switched to an instance

### Repository

* [x] A repository can be added
* [x] A repository can be deleted
* [x] A repository can be updated
* [x] The list with the available repositories shows the actual repositories

### Managing the proxy server

* [x] the server can be started
* [x] the server can be stopped
* [x] the server can be restarted
* [x] the server can be pruned (config files)
* [x] the configurations of the server can be reloaded
* [x] Changing host is possible
* [x] it's possible to login via cli

### Managing the salt server

* [x] the server can be started
* [x] the server can be stopped
* [x] the server can be restarted
* [x] the server can be pruned (keys)
* [x] it's possible to login via cli
* [x] the available states can be listed

### Additional functionalities

* [x] Currently installed instances can be listed
* [x] Currently running instances can be listed
* [ ] doil can be deinstalled (instances remain)
* [x] Version can be displayed
* [ ] Each command has its help page (sample)

### Global User Support (Linux only)

* [x] A new user can be added to the doil group
* [x] A user can be removed from the doil group
* [x] Registered users can be listed

## Environments

* [ ] Tested with Linux
* [ ] Tested with --global flag
* [ ] Tested with Windows
* [ ] Optional: Tested with MacOS
