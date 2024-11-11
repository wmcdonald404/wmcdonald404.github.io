#!/usr/bin/env bash
apt-get update
apt-get -y upgrade
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended