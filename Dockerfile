###################################################################
#
# Build Stage: base
#
###################################################################

FROM ubuntu:20.04 as build-base

WORKDIR /home

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update


###################################################################
#
# Build Stage: zsh
#
###################################################################

FROM build-base as build-zsh

# Install zsh shell with "Spaceship" theme and some customization.
# Uses some bundled plugins and installs some more from github
RUN apt-get install -qq curl \
    && sh -c "$(curl -sL https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)" -- \
        -t https://github.com/denysdovhan/spaceship-prompt \
        -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
        -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
        -p https://github.com/zsh-users/zsh-autosuggestions \
        -p https://github.com/zsh-users/zsh-completions \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "done"

# Copy these lines to the final-stage
#COPY --from=build-zsh /usr/bin/zsh /usr/bin/zsh
#COPY --from=build-zsh /root/.oh-my-zsh /root/.oh-my-zsh
#COPY --from=build-zsh /root/.zshrc /root/.zshrc


###################################################################
#
# Build Stage: vulcan
#
###################################################################

FROM build-base as build-vulcan

ARG VERSION=0.0.1

# Install fpm
RUN apt-get install -qq ruby ruby-dev rubygems build-essential \
    && gem install --no-document fpm \
    && echo "done"

# Build vulcan .deb package
COPY bin ./bin
COPY libexec ./libexec
COPY Makefile ./
COPY LICENSE ./
RUN make VERSION=${VERSION} build-deb


###################################################################
#
# Final Stage - dev
#
###################################################################

FROM build-base as final-dev

COPY --from=build-vulcan /home/vulcan_0.0.1_amd64.deb /tmp/vulcan_amd64.deb

# install vulcan
RUN apt-get install -qq /tmp/vulcan_amd64.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "done"

ENTRYPOINT ["/usr/bin/vulcan"]
