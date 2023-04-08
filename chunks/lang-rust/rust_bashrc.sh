#!/usr/bin/env bash

if test -e "${GITPOD_REPO_ROOT:-}"; then {
	export CARGO_HOME=/workspace/.cargo
	export PATH=$CARGO_HOME/bin:$PATH
}; fi
