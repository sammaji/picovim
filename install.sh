#!/usr/bin/env bash

# usage: ./install.sh [--version <x.y.z>]   (defaults to the latest release)
nvim_version="latest"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)
            if [[ -z "$2" ]]; then echo "--version requires a value"; exit 1; fi
            nvim_version="${2#v}"; shift 2 ;;
        --version=*)
            nvim_version="${1#--version=}"; nvim_version="${nvim_version#v}"; shift ;;
        *)
            echo "Unknown option: $1"; exit 1 ;;
    esac
done


# check if curl is installed.
if ! command -v curl &> /dev/null; then
    echo "curl not installed";
    exit 1;
fi


# check if git is installed.
if ! command -v git &> /dev/null; then
    echo "git is not installed";
    exit 1;
fi


install_neovim () {
    echo "#> Installing neovim ($nvim_version)..."
    case "$(uname -m)" in
        x86_64) arch="x86_64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac

    # releases before v0.10.4 shipped only an x86_64 build named nvim-linux64
    name="nvim-linux-${arch}"
    if [[ "$nvim_version" != "latest" ]] &&
       [[ "$(printf '%s\n' "$nvim_version" "0.10.4" | sort -V | head -n1)" != "0.10.4" ]]; then
        if [[ "$arch" != "x86_64" ]]; then
            echo "nvim v$nvim_version has no linux $arch build"; exit 1;
        fi
        name="nvim-linux64"
    fi

    if [[ "$nvim_version" == "latest" ]]; then
        url="https://github.com/neovim/neovim/releases/latest/download/${name}.tar.gz"
    else
        url="https://github.com/neovim/neovim/releases/download/v${nvim_version}/${name}.tar.gz"
    fi

    cd ~ || exit 1;
    if ! curl -fLO "$url"; then
        echo "Failed to download $url";
        exit 1;
    fi
    sudo rm -rf "/opt/${name}"
    sudo tar -C /opt -xzf "${name}.tar.gz"
    rm -f "${name}.tar.gz"

    path_line="export PATH=\"\$PATH:/opt/${name}/bin\""
    if ! grep -qxF "$path_line" ~/.bashrc 2> /dev/null; then
        echo "$path_line" >> ~/.bashrc
    fi
    export PATH="$PATH:/opt/${name}/bin"
    echo "Installed neovim."
}

# install neovim
if ! command -v nvim &> /dev/null; then
    read -rp "nvim is not installed. Would you like to install nvim ($nvim_version) (Y/n) " answer < /dev/tty
    answer=${answer:-y}
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        install_neovim;
    fi
fi


# install config
conf="$HOME/.config/nvim"
if [ -d "$conf" ]; then
    echo "Local config already exists."
    read -rp "Do you want to overwrite your local config? (y/N) " yy < /dev/tty
    yy=${yy:-n}
    if [[ "$yy" != "y" && "$yy" != "Y" ]]; then exit 0; fi
fi

echo "#> Setting up neovim config..."
rm -rf "$conf"
if ! git clone https://github.com/sammaji/picovim "$conf"; then
    echo "Failed to create neovim config."
    exit 1
fi
echo "Created local neovim config at $conf"


# install plugins (lazy.nvim bootstraps itself from lua/config/lazy.lua)
if command -v nvim &> /dev/null; then
    echo "#> Installing plugins..."
    nvim --headless "+Lazy! sync" +qa
    echo "Installed plugins."
else
    echo "nvim not found; plugins will be installed by lazy.nvim on first launch."
fi
