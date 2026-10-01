#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(cat ~/version 2>/dev/null || echo "0.9.29")
export ARCH VERSION
export OUTPATH=./dist

# Ignore inherited APPDIR from host AppImage mounts
case "${APPDIR:-}" in
	/tmp/.mount_*) unset APPDIR ;;
esac

export ICON=/usr/share/raddbg/logo.png
export DESKTOP=/usr/share/applications/raddbg.desktop
export DEPLOY_OPENGL=1

if [ -n "${GITHUB_REPOSITORY:-}" ]; then
	export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
	export ADD_HOOKS="${ADD_HOOKS:-self-updater.hook}"
fi

if [ -z "${CI:-}" ]; then
	export DWARFS_COMP="${DWARFS_COMP:-zstd:level=1}"
	export NO_STRIP="${NO_STRIP:-1}"
	export STRACE_TIME="${STRACE_TIME:-1}"
fi

# Deploy dependencies
quick-sharun /usr/bin/raddbg /usr/bin/radbin /usr/bin/radlink

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app
if [ -n "${CI:-}" ] || [ "${RUN_TEST:-0}" = "1" ]; then
	quick-sharun --test ./dist/*.AppImage
fi
