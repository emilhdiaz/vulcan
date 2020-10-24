FROM homebrew/brew:latest

# symlink greadlink to readlink
RUN ln -s /usr/bin/readlink /usr/bin/greadlink

# insntall apt-get dependencies
RUN apt-get update \
    && apt-get install -y zsh \
    && curl -sL https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | zsh || true \
    && rm -rf /var/lib/apt/lists/* \
    && echo "done"

# install brew dependencies, and supported vulcan insntallers (as a caching optimizations)
COPY Brewfile .
RUN brew update \
    && brew bundle \
    && brew install zsh \
    && brew install asdf nvm pyenv tfenv pipx \
    && echo "done"

# configure shell and home dir
ENV SHELL /bin/zsh
SHELL ["/bin/zsh", "-c"]
WORKDIR /home

# install vulcan CLI
COPY . .
RUN ln -s $(pwd)/bin/vulcan /usr/local/bin/vulcan

ENTRYPOINT ["/usr/local/bin/vulcan"]
