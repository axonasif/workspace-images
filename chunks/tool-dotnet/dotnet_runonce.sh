#!/usr/bin/env bash

if [ -n "${GITPOD_REPO_ROOT:-}" ]; then
	CONTAINER_DIR=$(awk '{ print $6 }' /proc/self/maps | grep '^/run/containerd' | head -n 1 | cut -d '/' -f 1-6)
	if [ -n "${CONTAINER_DIR}" ] && [ ! -d "${CONTAINER_DIR}" ]; then
		sudo sh <<-CMD
			mkdir -p "${CONTAINER_DIR}" && ln -s / "${CONTAINER_DIR}/rootfs"
		CMD
	fi
fi
