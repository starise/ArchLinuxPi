#!/usr/bin/env bash

set -o errtrace -o nounset -o pipefail -o errexit

# set up one shot resize root fs for first boot
mv /tmp/resizerootfs/resizerootfs.service /etc/systemd/system
mv /tmp/resizerootfs/resizerootfs /usr/sbin/
chmod 0644 /etc/systemd/system/resizerootfs.service
systemctl enable resizerootfs.service
