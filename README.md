# Vulcan

The Vulcan project helps developers install and maintain CLI tooling and packages on their Mac OSX machines across a 
variety of package managers. Vulcan uses a declarative YAML based configuration file to pin the packages and versions 
that should be installed on the machine. 
 
The main interface is through a CLI tool called `vulcan`, which will automatically look for a file named 
`vulcan-config.yml` in your current directory unless passed the `--config` option. 

## Pre-requisites

At minimum the Mac OSX environment should have [homebrew](https://brew.sh) and [yq](https://github.com/mikefarah/yq) 
installed. 


## Usage 

```bash
Usage: vulcan ACTION [OPTIONS]

ACTIONS:
  install                       Installs development tools
  help                          Prints this usage menu


Global OPTIONS:
  --config                      Path to the configuration file (default: vulcan-config.yml)
  --log-level                   The log level (default INFO)
  --dry-run                     Flag to indicate that the install is just a dry-run
```


### vulcan install

```
vulcan install [--config <vulcan-config.yml>]
```

Vulcan can help developers install and maintain other CLI tools and packages necessary for development. It utilizes a 
declarative specification to define the packages that should be installed, the desired versions of those packages, 
and the package manager (a.k.a installer) that should be used to install those packages.

Sample configuration in `vulcan-config.yml`:

```yaml
installers:
  - name: brew
  - name: asdf

programs:
  - name: awscli
    installer: brew
  - name: asdf
    installer: brew
  - name: direnv
    installer: asdf
  - name: helm
    installer: asdf
    version: 3.3.4
  - name: nodejs
    installer: asdf
    version: 14.13.0
```

*NOTE:* If a package version is omitted, then Vulcan assumes that you want to track the `latest` version of that package, 
and will check for updates every time the `install` command is run. 


Currently Vulcan supports installations through the following package managers: 
* brew (homebrew)
* asdf
* sdk (sdkman)
* pipx
* nvm (nodejs versions)
* pyenv (python versions)
* tfenv (terraform versions)

*NOTE:* We highly recommend that were possible you avoid using `brew` as the package manager as it does not allow you
to pin the exact minor version of a package that you need. Homebrew also generally promotes an upgrade only model and 
makes it rather difficult to downgrade to a specific minor version of a package. 

*NOTE:* We also highly recommend to use the `asdf` package manager when possible, as this package manager supports using 
a configuration file call `.tool-versions` within specific directories to pin which versions of a package should be 
activated when navigating into that directory (similar to direnv). This `.tool-versions` file can be committed to 
version control to synchronize environment and package requirements amongst a team of developers. 


## Future Enhancements

* Docker container rather than local dependencies.  

