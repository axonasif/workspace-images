#!/usr/bin/env bash

if test -e "${GITPOD_REPO_ROOT:-}"; then {
	CARGO_HOME="/workspace/.cargo"
	mkdir -p "$CARGO_HOME/bin" 2>/dev/null

	if test ! -e "$CARGO_HOME/bin/rustup" && rustup="$(command -v rustup)"; then {
		mv "${rustup}" "$CARGO_HOME/bin"
	}; fi
}; fi
