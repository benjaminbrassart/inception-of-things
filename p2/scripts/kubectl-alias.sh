#!/usr/bin/env sh

set -e

printf -- 'alias k=kubectl\n' | tee /etc/profile.d/kubectl.sh
