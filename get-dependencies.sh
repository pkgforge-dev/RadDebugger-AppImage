#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm git clang lld llvm freetype2 libx11 libxext libxfixes libgl libegl

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building RAD Debugger from upstream source..."
echo "---------------------------------------------------------------"
BUILD_DIR=$(mktemp -d)
git clone --depth=1 https://github.com/EpicGames/raddebugger.git "$BUILD_DIR"
cd "$BUILD_DIR"

# Build release targets: raddbg (GUI), radbin (binary/RDI inspector), radlink (linker)
./build.sh clang release raddbg radbin radlink

# Install binaries and assets to /usr
install -Dm0755 build/raddbg /usr/bin/raddbg
install -Dm0755 build/radbin /usr/bin/radbin
install -Dm0755 build/radlink /usr/bin/radlink
install -Dm0644 data/logo.png /usr/share/raddbg/logo.png
install -Dm0644 data/logo.png /usr/share/icons/hicolor/256x256/apps/raddbg.png

# Create desktop entry
mkdir -p /usr/share/applications
cat << 'EOF' > /usr/share/applications/raddbg.desktop
[Desktop Entry]
Name=RAD Debugger
Comment=Native user-mode graphical debugger
Exec=raddbg
Icon=raddbg
Type=Application
Terminal=false
Categories=Development;Debugger;
EOF

# Output version for make-appimage.sh
git describe --tags --always | sed 's/^v//' > ~/version

cd - >/dev/null
rm -rf "$BUILD_DIR"
