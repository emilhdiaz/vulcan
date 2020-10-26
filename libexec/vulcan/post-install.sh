#!/usr/bin/env sh

# symlink readlink to greadlink
ln -s "$(command -v readlink)" /usr/bin/greadlink

# symlink pre-packaged yq_amd64 to yq
ln -s /usr/libexec/yq_amd64 /usr/bin/yq
