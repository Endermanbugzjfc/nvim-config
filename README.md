```bash
docker run -w /root -it --rm alpine:latest sh -uelic '
  apk add git nodejs neovim ripgrep build-base wget --update
  git clone https://github.com/Endermanbugzjfc/nvim-config ~/.config/nvim
  nvim # prerequisites below are not included!
  '
```
![撚 𨶙 捻 년 ねん ㄋㄧㄢˇ](https://github.com/Endermanbugzjfc/nvim-config/assets/53002741/bb0f391f-a213-403e-a1c8-8e25d8b2a1c0)
<p align=center>
  <a href="https://github.com/NvChad/NvChad#plugins-list">
    <img src="https://img.shields.io/badge/total_plugins-34-green?style=for-the-badge" title="Total plugins (34)">
  </a>
  <a href="#custom-plugins">
    <img src="https://img.shields.io/badge/custom_plugins-7-blue?style=for-the-badge" title="Custom plugins (7)">
  </a>
  <a href="#which-theme-am-i-using-why-does-the-whole-interface-look-so-dull">
    <img src="https://img.shields.io/badge/works_on-my_machine-gold?style=for-the-badge" title="Made in China">
  </a>
  </br>
  <a href="https://github.com/SOF3/nvim-config">
    <img src="https://img.shields.io/badge/code_stolen_from-SOF3-64d958?style=for-the-badge" title="Inspired by SOF3">
  </a>
  <a href="https://github.com/f40a3204/nvim">
    <img src="https://img.shields.io/badge/code_stolen_from-f40a3204-fc73d5?style=for-the-badge" title="Inspired by f40a3204">
  </a>
  <a href="https://github.com/Endermanbugzjfc/sublime-text-config">
    <img src="https://img.shields.io/badge/sublime_text-yyds_goat-ff9800?style=for-the-badge&logo=sublime-text" title="Sublime Text 永遠的神">
  </a>
</p>

# Chit-chats on NvChad
As more and more Vim presets emerge,
many are prone to be spoiled for choices on their first glimpse at this whole new world.
Nevertheless, every coin has two sides and each Vim setup has its pros and cons.
Therefore, I would like to expose some shortcomings of NvChad that I have run into.
### 1. The nightmare of configure
There is no doubt that the DIY process has provided me with a lot of fun. However, many troubles appeared.
- Built-in systems, such as Tabufline and Statusline, have produced a certain difficulty for customisation as you can only work with [stringified modules](https://github.com/Endermanbugzjfc/nvim-config/blob/c88b4f48b6f3f522c8a83b77a544771867709834/lua/custom/statusline.lua#L20).
- Lack of caveats and guides in the official doc, especially for the installation of LSP. The tiniest step can cause an entire butterfly effect. I still recall the 2 hours I spent trying to figure out my LSP malfunctions because I forgot to make them inherit the default config.

*On second thought, it probably takes akin length of time to configure pure Nvim or other presets.*
### 2. Lazy.nvim doesn't fix Mojang code
I greatly appreciate that Lazy (the plugin manager) has helped the performance by leaps.
However, there are certain plugins that just can't follow the pace of me:
- nvim-tree.lua

# Which theme am I using? Why does the whole interface look so dull?
GitHub Light is my all-day colour scheme alongside a heavily stripped VSCode statusline.
It is not really as lacklustre for me as the above screenshot has shown.
Thanks to my 80% opacity of Windows Terminal,
with acrylic material disabled, I can read the documentation (or perhaps, loaf around) in the meantime of writing code.

Moreover, it is an attempt to boost my productivity by minimising the distractions, concerning this video:
```
https://youtu.be/_hnuEdrM-a0
```
*go copy the link urself don't accuse me rickroll'in*

This is also why there is so much stuff commented out for the statusline modules,
such as the [column number](https://github.com/Endermanbugzjfc/nvim-config/blob/c88b4f48b6f3f522c8a83b77a544771867709834/lua/custom/statusline.lua#L38), which updates too often.

In case you are curious, my Windows Terminal colour scheme is One Half Light,
with dimmed white / bright white mapped to
[![Silver Chalice](https://img.shields.io/badge/%20%23A8A8A8-A8A8A8)](https://imagecolorpicker.com/color-code/a8a8a8) /
<!-- #A8A8A8 -->
[![Alto](https://img.shields.io/badge/%20%23CFCFCF-CFCFCF)](https://imagecolorpicker.com/color-code/cfcfcf)
<!-- #CFCFCF -->
and had the font be [CaskaydiaCove Nerd Font](https://www.programmingfonts.org/#cascadia-code).

# Prerequisites
- Nvim installed as an [AppImage](https://github.com/vim/vim-appimage) since the one on APT is outdated.
- [`fd`](https://github.com/sharkdp/fd) or you gotta spend 69 hours trying to figure out why Telescope hates you.
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) in which I just treat it as the project-level search tool.
<!-- - NodeJS v16 (use NVM to switch version), cannot get Grammarly LSP 0.0.4 work on high Node versions. -->
- [`ra_multiplex`](https://github.com/pr2502/ra-multiplex) so rust-analyzer can cache.
- **Possess a seasoned level of skill to exit Vim.**

# Custom plugins
- [m-demare/attempt.nvim](https://github.com/m-demare/attempt.nvim) *Scratch files manager.*
- [echasnovski/mini.nvim](https://github.com/echasnovski/mini.nvim) *The "Swiss Army knife".*
- [tpope/vim-sleuth](https://github.com/tpope/vim-sleuth) *Tab width adaptation.*
- [tpope/vim-abolish](https://github.com/tpope/vim-abolish) *Advanced substitute.*
  - [markonm/traces.vim](https://github.com/markonm/traces.vim) *Highlight and preview.*
- [nvim-telescope/telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim) *UI for LSP code action.*
- [tzachar/cmp-tabnine](https://github.com/tzachar/cmp-tabnine) *GitHub Copilot alternative.*

