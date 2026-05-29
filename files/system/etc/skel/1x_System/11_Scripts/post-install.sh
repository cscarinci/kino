#!/bin/bash
set -euo pipefail

# ── Network check ─────────────────────────────────────────────
echo "Checking network connectivity..."
until curl -s --head https://github.com &>/dev/null; do
  echo "Waiting for network..."
  sleep 5
done
echo "Network OK."

# ── chezmoi ───────────────────────────────────────────────────
echo "Applying chezmoi..."
chezmoi init --source ~/1x_System/10_Config/dotfiles git@github.com:cscarinci/chezmoi.git
chezmoi apply
echo "Chezmoi applied."

# ── Clone kino repo ───────────────────────────────────────────
echo "Cloning kino repo..."
git clone git@github.com:cscarinci/kino.git ~/1x_System/10_Config/kino
echo "Kino repo cloned."

# ── Brew packages ─────────────────────────────────────────────
echo "Installing brew packages..."
brew install \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  isync \
  mu \
  pandoc \
  imagemagick \
  ffmpeg \
  rclone \
  restic
echo "Brew packages installed."

# ── TexLive ───────────────────────────────────────────────────
echo "Installing TexLive (this will take a while)..."
cd /tmp
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
cd install-tl-*/
./install-tl --profile ~/1x_System/12_TexLive/texlive.profile
echo "TexLive installed."

echo "Post-install complete. Please restart your shell."
