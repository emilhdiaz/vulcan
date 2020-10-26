# Vulcan

Vulcan helps developers install and maintain CLI tools and packages on their Mac OSX and Linux machines across a 
variety of package managers (referenced as "installers" here on forth) . It uses a declarative YAML based configuration 
to define the packages that should be installed, the desired versions of those packages, and the specific installer that 
should be used to install those packages. This allows you you to manage all your packages from a single location. 
 
Sample configuration file: 
 
 ```yaml
 installers:
   - name: nvm
   - name: pyenv
   - name: asdf
 
 programs:
   - name: jq
   - name: curl
   - name: awscli
   - name: direnv
   - name: vulcan
     tap: emilhdiaz/tap
     tap-url: https://github.com/emilhdiaz/homebre-tap.git
   - name: helm
     installer: asdf
     version: 3.3.4
   - name: nodejs
     installer: nvm
     version: 14.13.0
   - name: python
     installer: pyenv
     version: 3.8.6
     requires:
       - bzip2
       - sqlite3
 ```
 
Supported config directives:
 
 | Directive   | Description |
 | ----------- | ----------- |
 | .installers | A list of installers that need to be installed on this machine. Vulcan will decide the best way to install these installers. It may use the system's native installer or a custom installation script based on the recommendations of the installer's authors |
 | .installers.name | The name of the installer (currently supported: `brew`, `apt-get`, `asdf`, `sdk` (sdkman), `pipx`, `nvm`, `pyenv`, `tfenv` | 
 | .programs | A list of programs (tools, packages) that need to be installed on this machine | 
 | .programs.name | The name of the program to install |
 | .programs.installer | The installer that should be used to install this program |
 | .programs.version | The specific version of this package to install and pin. Defaults to `latest`, which means that this package will always be updated to the latest version available |
 | .programs.requires | A list of required OS packages that need to be pre-installed before this program is installed. Vulcan will only use the native installer to install these dependencies |
 | .programs.tap | (Homebrew Only / Optional) - The custom Homebrew tap to use for this package |
 | .programs.tap-url | (Homebrew Only / Optional) - The custom Homebrew tap URL to use for this package |
 

Selecting which installers to use: 

Recognizing that the choice of which installer to use is a personal choice (after all, that flexibility is what Vulcan
aims to provide!), we do have some recommendations: 

* For any CLI tools that you don't need to pin versions down to a particular patch version (i.e. `x.y.z`), we recommend that you primarily use the native installer (`brew | apt-get`) if the package is available. 
* For programming languages that you need to install and maintain multiple concurrent versions on your machine, we recommend that you use the installer specific to that language: 
  * `pyenv` - For Python
  * `nvm` - For NodeJS
  * `sdk` - For Java
* For any other CLI tools or packages that you need a specific patch version, we recommend that you do not use the native installer (`brew | apt-get`) as it will not allow you to pin this level of specificity for the version. Instead, use an alternate installer that supports your package like `asdf`, `pipx`, `sdf`, or `tfenv`.
* *NOTE*: Vulcan exclusively focuses the installation and management of CLI tools. We do not recommend that you use Vulcan to manage application runtime dependencies. Those dependencies should continue to be managed installed through package managers such as `pip` (requirements.txt), `npm` (package.json), or `maven` (pom.xml). 
  
The Vulcan CLI:

Vulcan's main interface is through a CLI tool called `vulcan`, which will automatically look for a file named 
`vulcan-config.yml` in your current directory unless passed the `--config` option.


## Pre-requisites

Currently Vulcan is only supported for the `zsh` shell and requires a native installer (`brew | apt-get`) to be 
pre-installed on the machine.   

##### MacOx
At minimum the Mac OSX environment should have [homebrew](https://brew.sh) installed and the following packages pre-installed: 
* [coreutils](https://formulae.brew.sh/formula/coreutils)
* [curl](https://formulae.brew.sh/formula/curl) 
* [yq](https://github.com/mikefarah/yq)
* [jq](https://formulae.brew.sh/formula/jq)  

All these dependencies can be found in the `Brewfile` found in this repo and installed with: 
```bash
brew bundle
```

##### Debian Linux
At minimum the Debian environment should have [apt-get](https://help.ubuntu.com/community/AptGet/Howto) and the 
following packages pre-installed:
* [coreutils](https://packages.ubuntu.com/focal/coreutils)
* [curl](https://packages.ubuntu.com/focal/curl)
* [yq](https://github.com/mikefarah/yq)
* [jq](https://packages.ubuntu.com/focal/jq) 


## Installation

Vulcan can be installed 

Via `brew`: 
```bash
brew tap emilhdiaz/tap
brew install vulcan
```

Via `apt-get`: 
```bash
brew tap emilhdiaz/tap
brew install vulcan
```

Manually (replace `<DIR>` below with the directory you'd like to clone the repository into):
```bash
# Step 1 - Clone this repository
git clone https://github.com/emilhdiaz/vulcan.git <DIR>

# Step 2 - OS X install pre-requisites
brew bundle

# Step 2 - Debian install pre-requisites
apt-get install -y coreutils curl yq jq

# Step 3 - Add to .bashrc / .zshrc / .profile
export PATH="<DIR>/vulcan/bin:${PATH}"
```

A base image for Docker also exists:
```bash
FROM emilhdiaz/vulcan
```


## Usage 

```bash
Usage: vulcan ACTION [OPTIONS]

ACTIONS:
  install                       Installs all installers and programs as specified in the supplied vulcan configuration file
  help                          Prints this usage menu


Global OPTIONS:
  --config                      Path to the configuration file (default: vulcan-config.yml)
  --log-level                   The log level (default INFO)
  --dry-run                     Flag to indicate that the install is just a dry-run
```

## Contributions

Community contributions are welcome. Please raise a Github Issue to capture the changes you'd like to see applied to 
the tool and submit Pull Requests that reference that Issue. 


## License 
MIT
