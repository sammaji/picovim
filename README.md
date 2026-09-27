# pico - my vim and neovim conf

simple minimal vim and neovim config

## setup

### quick install (linux)

make sure you have `curl` and `git` installed. then run:

```bash
curl -fsSL https://raw.githubusercontent.com/sammaji/picovim/main/install.sh | bash
```

this installs the latest neovim release (if nvim isn't already installed), clones the config into `~/.config/nvim` and installs all the plugins. to install a specific neovim version instead:

```bash
curl -fsSL https://raw.githubusercontent.com/sammaji/picovim/main/install.sh | bash -s -- --version 0.11.4
```

### manual install

make sure you have neovim `0.10+` and `git` installed. then run the following commands:

```bash
git clone https://github.com/sammaji/picovim ~/.config/nvim
```

then run `:LazyInstall` to install all the plugins.

that's it ^^

## theme

use `:Themery` to switch themes (my current theme is everforest).

## screenshots
![kanagawa](https://github.com/user-attachments/assets/ff1693d6-d784-44a6-a7b2-dc6becee5efc)
![rose_pine_transparent](https://github.com/user-attachments/assets/d98a1423-c4d2-40d9-bdce-608d5fc976c4)
