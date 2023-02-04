#!/bin/bash
# install and configure vim ide for amzn2 linux

DENO_VERSION="v1.30.2"

echo "Hello, setting up Vim IDE"

echo "Going to install required packages"
sudo yum install -y git zsh fuse util-linux-user

export DENO_INSTALL="${HOME}/.local"
export NODE_VERSION=16
export XDG_CONFIG_HOME="${HOME}/.config"
PORTABLE="${XDG_CONFIG_HOME}/portable"

if [[ -d ${PORTABLE} ]]; then
    echo "Already installed portable"
else
    echo "Getting our configs"
    mkdir -vp "${PORTABLE}"
    mkdir -vp "${HOME}/.local/bin"
    git clone https://github.com/Stratold/nvim-ide.git "${PORTABLE}"
fi

echo "Installing configs"
for l in tmux.conf vim zshrc.local zshrc; do
    ln -svrf -T "${PORTABLE}/${l}" "${HOME}/.${l}"
done

mkdir -pv "${XDG_CONFIG_HOME}/nvim"
cat <<EOF > "${XDG_CONFIG_HOME}/nvim/init.vim"
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vim/vimrc
EOF

export PROFILE="${HOME}/.zshrc.local"  # for nvm

curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
curl -fsSLo "${HOME}/.local/bin/nvim" https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
curl -fsSLo "${HOME}/.local/bin/tmux" https://github.com/nelsonenzo/tmux-appimage/releases/download/3.2a/tmux.appimage

bash "${PORTABLE}/deno-install.sh" "${DENO_VERSION}"

source "${XDG_CONFIG_HOME}/nvm/nvm.sh"

URLS=(
    "https://github.com/terraform-linters/tflint/releases/download/v0.44.1/tflint_linux_amd64.zip"
    "https://releases.hashicorp.com/terraform-ls/0.30.1/terraform-ls_0.30.1_linux_amd64.zip"
    "https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip"
)

for url in "${URLS[@]}"; do
    tmpdir="$(mktemp -d)"
    curl -fsSLo "${tmpdir}/arch.zip" "${url}"
    unzip "${tmpdir}/arch.zip" -d "${HOME}/.local/bin"
    rm -rf "${tmpdir}"
done

chmod -v a+x "${HOME}"/.local/bin/*
npm install --global neovim typescript typescript-language-server pyright
sudo chsh -s /usr/bin/zsh "$(id -un)"

"${HOME}/.local/bin/nvim" --headless -c PlugInstall -c :q -c :q

