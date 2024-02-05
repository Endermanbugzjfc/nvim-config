![image](https://github.com/Endermanbugzjfc/nvim-config/assets/53002741/bb0f391f-a213-403e-a1c8-8e25d8b2a1c0)
<p align=center>
  <a href=https://github.com/NvChad/NvChad#plugins-list>
    <img src=https://img.shields.io/badge/total_plugins-29-green?style=for-the-badge title="Total plugins (30)">
  </a>
  <a href=lua/custom>
    <img src="https://img.shields.io/badge/custom_plugins-2-blue?style=for-the-badge" title="Custom plugins (3)">
  </a>
</p>

# Small talks on NvChad
As more and more Vim presets emerge, many are prone to be spoiled for choices on their first glimpse at this whole new world. Nevertheless, every coin has two sides and each Vim setup has its pros and cons. Therefore, I would like to expose some shortcomings of NvChad that I have run into.
## 1. The nightmare of configure
There is no doubt that the DIY process has provided me with a lot of fun. However, alongside many troubles.
- Built-in systems, such as Tabufline and Statusline, have produced a certain difficulty for customisation as you can only work with stringified modules.
- Lack of caveats and guides in the official doc, especially for the installation of LSP. The tiniest step can cause an entire butterfly effect. I still recall the 2 hours I spent trying to figure out that my LSP malfunctions because I forgot to make them inherit the default config.
# Prerequisites
- `fd` or you gotta spend 69 hours trying to figure out why Telescope hates you.
# Custom plugins
- [m-demare/attempt.nvim](https://github.com/m-demare/attempt.nvim) *Scratch files manager.*
- [echasnovski/mini.nvim](https://github.com/echasnovski/mini.nvim) *The "Swiss Army knife".*
