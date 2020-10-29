#!/usr/bin/env bash

# Title:         reconin.sh
# Description:   subdomain enumeration & takeover
# Author:        yuraloginoff <yuretsmolodets@yandex.ru>
# Date:          2020-mm-dd
# Version:       1.0.0

# Exit codes
# ==========
# 0   no error
# 1   script interrupted

# >>>>>>>>>>>>>>>>>>>>>>>> Functions >>>>>>>>>>>>>>>>>>>>>>>>

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

# <<<<<<<<<<<<<<<<<<<<<<<< Functions <<<<<<<<<<<<<<<<<<<<<<<<

# Exit if no arguments
if [[ $# -eq 0 ]]; then
	err "Usage: $0 domain.com"
	exit 1
fi
