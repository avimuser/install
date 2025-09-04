#!/bin/bash

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

pacman -Syu --needed --noconfirm \
    sudo man-db openssh git base-devel reflector wl-clipboard \
    fzf fish stow wget neovim direnv git \
    gcc go npm

CONFIG_MIRROR="https://raw.githubusercontent.com/avimuser/install/master"
wget "$CONFIG_MIRROR/arch-wsl/reflector.conf" -O /etc/xdg/reflector/reflector.conf
wget "$CONFIG_MIRROR/arch-wsl/reflector.timer" -O /usr/lib/systemd/system/reflector.timer
systemctl enable reflector.timer

ln -sf /bin/nvim /bin/vi
ln -sf /bin/nvim /bin/vim

USERNAME=avimuser
useradd -mG wheel $USERNAME
echo "[user]" >> /etc/wsl.conf
echo "default=$USERNAME" >> /etc/wsl.conf

chsh $USERNAME -s /bin/fish

echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
su - $USERNAME -c '
mkdir -p $HOME/Projects $HOME/.config
git clone https://github.com/avimuser/dotfiles $HOME/Projects/dotfiles
cd $HOME/Projects/dotfiles && stow config -t $HOME/.config

git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin && makepkg -si && cd .. && rm -rf paru-bin
paru -S antidot-bin ani-cli --skipreview --noconfirm
antidot update
cd ~
rm .bash*
'
sed -i '$d' /etc/sudoers
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

clear
echo "Changing root password"
passwd
echo "Changing $USERNAME password"
passwd $USERNAME
