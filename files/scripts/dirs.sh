#!/bin/bash
set -euo pipefail

mkdir -p /etc/skel/0x_Inbox/Desktop
mkdir -p /etc/skel/0x_Inbox/Downloads
mkdir -p /etc/skel/0x_Inbox/Templates
mkdir -p /etc/skel/0x_Inbox/Public
mkdir -p /etc/skel/1x_System
mkdir -p /etc/skel/2x_Work
mkdir -p /etc/skel/3x_Personal
mkdir -p /etc/skel/4x_References/Documents
mkdir -p /etc/skel/5x_Media/Music
mkdir -p /etc/skel/5x_Media/Pictures
mkdir -p /etc/skel/5x_Media/Videos
mkdir -p /etc/skel/0x_Inbox/00_Org
mkdir -p /etc/skel/.config

cat > /etc/skel/.config/user-dirs.dirs << 'UDEOF'
XDG_DESKTOP_DIR="$HOME/0x_Inbox/Desktop"
XDG_DOWNLOAD_DIR="$HOME/0x_Inbox/Downloads"
XDG_TEMPLATES_DIR="$HOME/0x_Inbox/Templates"
XDG_PUBLICSHARE_DIR="$HOME/0x_Inbox/Public"
XDG_DOCUMENTS_DIR="$HOME/4x_References/Documents"
XDG_MUSIC_DIR="$HOME/5x_Media/Music"
XDG_PICTURES_DIR="$HOME/5x_Media/Pictures"
XDG_VIDEOS_DIR="$HOME/5x_Media/Videos"
UDEOF
