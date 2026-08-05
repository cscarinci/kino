#!/usr/bin/env bash
# kino image build - runs inside the Containerfile, bind-mounted at /ctx.
set -ouex pipefail

cp -avf /ctx/system_files/. /

# ── Repos ────────────────────────────────────────────────────────────
# (none - starship moved to brew with the rest of the modern CLI set,
# which retired the atim/starship copr, the image's last third-party repo)

# ── Packages ─────────────────────────────────────────────────────────
# NOT re-added (already in the kinoite-main base): fcitx5, fcitx5-hangul,
# fcitx5-configtool, fcitx5-qt, fcitx5-gtk, kcm-fcitx5,
# google-noto-sans-cjk-fonts, fzf, distrobox, just, ffmpeg (full codecs).
#
# NOT here (installed via brew, see chezmoi's Brewfile): starship, atuin,
# zsh-autosuggestions, zsh-syntax-highlighting, eza, bat, ripgrep, fd,
# zoxide, git-delta, trash-cli, fastfetch, btop, shellcheck, pandoc,
# neovim, rclone, restic. chezmoi + gh stay: first login needs them
# before brew exists.
#
# Some packages below ARE already in the base but only incidentally -
# via the dependency closure (jq: anchored to nothing; ImageMagick: dep
# of braille-printer-app; 7zip: dep of ark) or via ublue's negativo17
# override (libva-intel-media-driver, hardware-critical, from a repo
# that ships enabled=0). Installing them explicitly asserts presence at
# every build: if the base reshuffles, the build either supplies them
# or fails loudly - never silently ships without them.
dnf5 -y install \
    emacs \
    autoconf \
    automake \
    poppler-glib-devel \
    libpng-devel \
    zlib-devel \
    enchant2-devel \
    hunspell-pt-BR \
    hunspell-ko \
    kitty \
    zsh \
    jq \
    zathura \
    zathura-pdf-poppler \
    ImageMagick \
    perl \
    powertop \
    chezmoi \
    7zip \
    podman-compose \
    gh \
    quickemu \
    tailscale \
    syncthing \
    papirus-icon-theme \
    papirus-icon-theme-dark \
    libva-intel-media-driver \
    google-roboto-fonts \
    rsms-inter-fonts \
    alerque-libertinus-fonts \
    google-noto-serif-cjk-fonts \
    naver-nanum-fonts-all

dnf5 -y remove firefox firefox-langpacks

# ── Nerd fonts (not packaged in Fedora) ──────────────────────────────
# Pinned release; bump deliberately. D2Coding = Korean monospace with
# real Hangul glyphs for the terminal.
NF_VERSION="v3.4.0"
NF_FONTS=(
    JetBrainsMono
    NerdFontsSymbolsOnly
    FiraCode
    Hack
    SourceCodePro
    CascadiaCode
    Iosevka
    Monaspace
    D2Coding
)
for font in "${NF_FONTS[@]}"; do
    dir="/usr/share/fonts/nerd-fonts/${font}"
    mkdir -p "${dir}"
    curl -fsSL --retry 3 \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/${NF_VERSION}/${font}.tar.xz" |
        tar -xJ -C "${dir}"
    # Tarballs carry LICENSE/README and mix ttf/otf per font - keep fonts only.
    find "${dir}" -type f ! -name '*.ttf' ! -name '*.otf' -delete
done
fc-cache --system-only --force

# ── Services ─────────────────────────────────────────────────────────
systemctl enable tailscaled.service
systemctl enable kino-flatpak-setup.service
systemctl enable kino-flatpak-update.timer
systemctl --global enable kino-flatpak-user-update.timer
# The base enables its own flatpak update timers (ublue-os-update-services;
# metered-guarded but lacking the wake-race wait and retry). Ours replace
# them - without this, two system and two user updaters run side by side.
# If the base ever renames these units, the disables no-op harmlessly.
systemctl disable flatpak-system-update.timer
systemctl --global disable flatpak-user-update.timer

# ── Cleanup ──────────────────────────────────────────────────────────
# Image /var is discarded by ostree at deploy time; empty it so
# `bootc container lint` stays warning-free. tailscaled recreates its
# state dir at runtime via StateDirectory=.
rm -rf /var/lib/dnf /var/lib/tailscale
