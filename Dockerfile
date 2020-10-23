# syntax=docker/dockerfile:1.0.0-experimental

FROM homebrew/brew:latest

# install general OS dependencies
RUN apt-get update && \
    apt-get -y install \
        curl \
        libssl-dev

# install zsh shell
RUN apt-get -y install zsh && \
    curl -sL https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | zsh || true
ENV SHELL /bin/zsh
SHELL ["/bin/zsh", "-c"]

# install vulcan supported installers (as a caching optimization)
RUN brew update && \
    brew install asdf nvm pyenv tfenv pipx

# install adt CLI
COPY . .
RUN ln -s $(pwd)/bin/vulcan /usr/local/bin/vulcan

# install adt dependencies
RUN brew bundle

ENTRYPOINT ["/usr/local/bin/vulcan"]
