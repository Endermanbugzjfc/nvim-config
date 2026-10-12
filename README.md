**This repo is supposed to used as config by NvChad users!**

- The main nvchad repo (NvChad/NvChad) is used as a plugin by this repo.
- So you just import its modules , like `require "nvchad.options" , require "nvchad.mappings"`
- So you can delete the .git from this repo ( when you clone it locally ) or fork it :)

Python files can display inline images with comment declarations:

```python
# image.nvim: path=./assets/model.png
# image.nvim: path=./assets/model.png width=40
# image.nvim: path=./assets/model.png height=20
# image.nvim: path=./assets/model.png width=40 height=20
```

Paths are relative to the Python file. Width and height are independently optional,
measured in terminal cells, and can appear in either order. The `image` snippet
inserts a declaration. Image updates are debounced, unchanged declarations reuse
their images, and image.nvim handles scrolling.

# Credits

1) Lazyvim starter https://github.com/LazyVim/starter as nvchad's starter was inspired by Lazyvim's . It made a lot of things easier!
